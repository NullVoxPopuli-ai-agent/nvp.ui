import { click, findAll, render } from "@ember/test-helpers";
import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";

import { pageLinks, pageSlots, Pagination } from "#src/index.ts";

function pagesShown() {
  return findAll("[data-page]").map((button) => button.textContent?.trim());
}

module("Pagination", function (hooks) {
  setupRenderingTest(hooks);

  test("renders the edges, the pages, and marks the current one", async function (assert) {
    const links = pageLinks(2, 3, (page) => assert.step(`go:${page}`));

    await render(<template><Pagination @links={{links}} /></template>);

    assert.dom("nav").hasAttribute("aria-label", "Pagination");
    assert.dom("button[aria-current='page']").hasText("2");
    assert.deepEqual(pagesShown(), ["1", "2", "3"]);
    assert.dom("[data-rel='first']").isEnabled();
    assert.dom("[data-rel='prev']").isEnabled();
    assert.dom("[data-rel='next']").isEnabled();
    assert.dom("[data-rel='last']").isEnabled();

    await click("[data-rel='next']");
    await click("[data-rel='prev']");
    await click("[data-rel='first']");
    await click("[data-rel='last']");
    await click("button[aria-current='page']");

    assert.verifySteps(["go:3", "go:1", "go:1", "go:3", "go:2"]);
  });

  test("the edges stay in place and disable at the ends", async function (assert) {
    const first = pageLinks(1, 3, () => {});

    await render(<template><Pagination @links={{first}} @label="Fruit pages" /></template>);

    assert.dom("nav").hasAttribute("aria-label", "Fruit pages");
    assert.dom("li").exists({ count: 7 });
    assert.dom("[data-rel='first']").isDisabled();
    assert.dom("[data-rel='prev']").isDisabled();
    assert.dom("[data-rel='next']").isEnabled();
    assert.dom("[data-rel='last']").isEnabled();

    const last = pageLinks(3, 3, () => {});

    await render(<template><Pagination @links={{last}} /></template>);

    assert.dom("li").exists({ count: 7 });
    assert.dom("[data-rel='next']").isDisabled();
    assert.dom("[data-rel='last']").isDisabled();
    assert.dom("[data-rel='prev']").isEnabled();
    assert.dom("[data-rel='first']").isEnabled();
  });

  test("the row of pages slides but keeps its size", async function (assert) {
    const start = pageLinks(1, 20, () => {});

    await render(<template><Pagination @links={{start}} /></template>);

    assert.deepEqual(pagesShown(), ["1", "2", "3", "4", "5"]);

    const middle = pageLinks(10, 20, () => {});

    await render(<template><Pagination @links={{middle}} /></template>);

    assert.deepEqual(pagesShown(), ["8", "9", "10", "11", "12"]);

    const end = pageLinks(20, 20, () => {});

    await render(<template><Pagination @links={{end}} @pageSlots={{3}} /></template>);

    assert.deepEqual(pagesShown(), ["18", "19", "20"]);
  });

  test("with WarpDrive's links, pages not loaded yet are disabled slots", async function (assert) {
    // pages 1 and 5 are loaded; 2 through 4 are a placeholder, as WarpDrive yields them
    const links = {
      prev: null,
      next: { isReal: true as const, text: "next", isCurrent: false, setActive: async () => {} },
      first: { isReal: true as const, text: "first", isCurrent: true, setActive: async () => {} },
      last: { isReal: true as const, text: "last", isCurrent: false, setActive: async () => {} },
      links: [
        { isReal: true as const, text: "1", isCurrent: true, setActive: async () => {} },
        { isReal: false as const, text: ".", indexRange: [2, 4] as const },
        { isReal: true as const, text: "5", isCurrent: false, setActive: async () => {} },
      ],
    };

    await render(<template><Pagination @links={{links}} /></template>);

    assert.deepEqual(pagesShown(), ["1", "2", "3", "4", "5"]);
    assert.dom("button[aria-current='page']").hasText("1");
    assert.dom("[data-page='3']").isDisabled();
    assert.dom("[data-page='5']").isEnabled();
    assert.dom("[data-rel='first']").isDisabled();
    assert.dom("[data-rel='prev']").isDisabled();
    assert.dom("[data-rel='next']").isEnabled();
    assert.dom("[data-rel='last']").isEnabled();
  });

  test("cursor pagination has edges and no page slots", async function (assert) {
    const links = {
      prev: null,
      next: { isReal: true as const, text: "next", isCurrent: false, setActive: async () => {} },
      links: [],
    };

    await render(<template><Pagination @links={{links}} /></template>);

    assert.dom("[data-page]").doesNotExist();
    assert.dom("li").exists({ count: 4 });
    assert.dom("[data-rel='next']").isEnabled();
  });
});

module("pageSlots", function () {
  test("centers the window on the current page and clamps it to the ends", function (assert) {
    const shown = (current: number, total: number) =>
      pageSlots(
        pageLinks(current, total, () => {}),
        5,
      ).map((slot) => slot.page);

    assert.deepEqual(shown(1, 20), [1, 2, 3, 4, 5]);
    assert.deepEqual(shown(3, 20), [1, 2, 3, 4, 5]);
    assert.deepEqual(shown(4, 20), [2, 3, 4, 5, 6]);
    assert.deepEqual(shown(19, 20), [16, 17, 18, 19, 20]);
    assert.deepEqual(shown(2, 2), [1, 2]);
  });
});

module("pageLinks", function () {
  test("every page is a link, with the edges", function (assert) {
    const links = pageLinks(2, 3, () => {});

    assert.deepEqual(
      links.links.map((link) => link.text),
      ["1", "2", "3"],
    );
    assert.strictEqual(links.prev?.text, "Previous");
    assert.strictEqual(links.next?.text, "Next");
    assert.strictEqual(links.first?.text, "First");
    assert.strictEqual(links.last?.text, "Last");
  });

  test("a single page has no edges", function (assert) {
    const links = pageLinks(1, 1, () => {});

    assert.deepEqual(
      links.links.map((link) => link.text),
      ["1"],
    );
    assert.strictEqual(links.prev, null);
    assert.strictEqual(links.next, null);
    assert.strictEqual(links.first, null);
    assert.strictEqual(links.last, null);
  });
});
