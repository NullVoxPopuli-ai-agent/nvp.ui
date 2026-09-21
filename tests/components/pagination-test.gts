import Service from "@ember/service";
import { findAll, render } from "@ember/test-helpers";
import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";

import { pageSlots, Pagination } from "#src/index.ts";

function pagesShown() {
  return findAll("[data-page]").map((link) => link.textContent?.trim());
}

function hrefOf(selector: string) {
  const href = document.querySelector(selector)?.getAttribute("href") ?? "";

  // withQP builds an absolute URL; only the path and query matter here
  return href.replace(location.origin, "");
}

module("Pagination", function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    // withQP reads the current URL from the router service
    class RouterStub extends Service {
      currentURL = "/fruit?sort=name&page=2";
    }

    this.owner.register("service:router", RouterStub);
  });

  test("links set the page query param and keep the others", async function (assert) {
    await render(<template><Pagination @page={{2}} @totalPages={{3}} /></template>);

    assert.dom("nav").hasAttribute("aria-label", "Pagination");
    assert.deepEqual(pagesShown(), ["1", "2", "3"]);
    assert.dom("a[data-page]").exists({ count: 3 });
    assert.dom("a[aria-current='page']").hasText("2");

    assert.strictEqual(hrefOf("[data-rel='first']"), "/fruit?sort=name&page=1");
    assert.strictEqual(hrefOf("[data-rel='prev']"), "/fruit?sort=name&page=1");
    assert.strictEqual(hrefOf("[data-page='3']"), "/fruit?sort=name&page=3");
    assert.strictEqual(hrefOf("[data-rel='next']"), "/fruit?sort=name&page=3");
    assert.strictEqual(hrefOf("[data-rel='last']"), "/fruit?sort=name&page=3");
  });

  test("the query param name can change", async function (assert) {
    await render(<template><Pagination @page={{2}} @totalPages={{3}} @param="p" /></template>);

    assert.strictEqual(hrefOf("[data-rel='next']"), "/fruit?sort=name&page=2&p=3");
  });

  test("the edges stay in place and go nowhere at the ends", async function (assert) {
    await render(
      <template><Pagination @page={{1}} @totalPages={{3}} @label="Fruit pages" /></template>,
    );

    assert.dom("nav").hasAttribute("aria-label", "Fruit pages");
    assert.dom("li").exists({ count: 7 });
    assert.dom("[data-rel='first']").doesNotHaveAttribute("href");
    assert.dom("[data-rel='first']").hasAria("disabled", "true");
    assert.dom("[data-rel='prev']").doesNotHaveAttribute("href");
    assert.dom("[data-rel='next']").hasAttribute("href");
    assert.dom("[data-rel='last']").hasAttribute("href");

    await render(<template><Pagination @page={{3}} @totalPages={{3}} /></template>);

    assert.dom("li").exists({ count: 7 });
    assert.dom("[data-rel='next']").doesNotHaveAttribute("href");
    assert.dom("[data-rel='last']").doesNotHaveAttribute("href");
    assert.dom("[data-rel='prev']").hasAttribute("href");
    assert.dom("[data-rel='first']").hasAttribute("href");
  });

  test("the symbol leads on backward controls and trails on forward ones", async function (assert) {
    await render(<template><Pagination @page={{2}} @totalPages={{3}} /></template>);

    assert.dom("[data-rel='prev']").hasText("‹ Previous");
    assert.dom("[data-rel='next']").hasText("Next ›");
    assert.dom("[data-rel='last']").hasText("Last »");
  });

  test("the row of pages slides but keeps its size", async function (assert) {
    await render(<template><Pagination @page={{1}} @totalPages={{20}} /></template>);

    assert.deepEqual(pagesShown(), ["1", "2", "3", "4", "5"]);

    await render(<template><Pagination @page={{10}} @totalPages={{20}} /></template>);

    assert.deepEqual(pagesShown(), ["8", "9", "10", "11", "12"]);

    await render(
      <template><Pagination @page={{20}} @totalPages={{20}} @pageSlots={{3}} /></template>,
    );

    assert.deepEqual(pagesShown(), ["18", "19", "20"]);
  });
});

module("pageSlots", function () {
  test("centers the window on the current page and clamps it to the ends", function (assert) {
    assert.deepEqual(pageSlots(1, 20, 5), [1, 2, 3, 4, 5]);
    assert.deepEqual(pageSlots(3, 20, 5), [1, 2, 3, 4, 5]);
    assert.deepEqual(pageSlots(4, 20, 5), [2, 3, 4, 5, 6]);
    assert.deepEqual(pageSlots(19, 20, 5), [16, 17, 18, 19, 20]);
    assert.deepEqual(pageSlots(2, 2, 5), [1, 2]);
    assert.deepEqual(pageSlots(1, 0, 5), []);
  });
});
