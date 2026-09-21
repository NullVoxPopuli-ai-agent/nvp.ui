import { click, render } from "@ember/test-helpers";
import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";

import { pageLinks, Pagination } from "#src/index.ts";

module("Pagination", function (hooks) {
  setupRenderingTest(hooks);

  test("renders numbered pages, the current one marked, and prev / next", async function (assert) {
    const links = pageLinks(2, 3, (page) => assert.step(`go:${page}`));

    await render(<template><Pagination @links={{links}} /></template>);

    assert.dom("nav").hasAttribute("aria-label", "Pagination");
    assert.dom("button[aria-current='page']").hasText("2");
    assert.dom("li button:not([data-rel])").exists({ count: 3 });
    assert.dom("[data-rel='prev']").isEnabled();
    assert.dom("[data-rel='next']").isEnabled();

    await click("[data-rel='next']");
    await click("[data-rel='prev']");
    await click("button[aria-current='page']");

    assert.verifySteps(["go:3", "go:1", "go:2"]);
  });

  test("on the first page, prev is disabled; on the last, next is", async function (assert) {
    const first = pageLinks(1, 3, () => {});

    await render(<template><Pagination @links={{first}} @label="Fruit pages" /></template>);

    assert.dom("nav").hasAttribute("aria-label", "Fruit pages");
    assert.dom("[data-rel='prev']").isDisabled();
    assert.dom("[data-rel='next']").isEnabled();

    const last = pageLinks(3, 3, () => {});

    await render(<template><Pagination @links={{last}} /></template>);

    assert.dom("[data-rel='next']").isDisabled();
    assert.dom("[data-rel='prev']").isEnabled();
  });

  test("gaps render as an ellipsis that screen readers skip", async function (assert) {
    const links = pageLinks(10, 20, () => {});

    await render(<template><Pagination @links={{links}} /></template>);

    assert.dom(".nvp__pagination__gap").exists({ count: 2 });
    assert.dom(".nvp__pagination__gap").hasAttribute("aria-hidden", "true");
    // 1 … 8 9 10 11 12 … 20
    assert.dom("li button:not([data-rel])").exists({ count: 7 });
  });

  test("accepts the shape WarpDrive's EachLink yields", async function (assert) {
    // the same fields RealPaginationLink and PlaceholderPaginationLink expose
    const links = {
      prev: null,
      next: { isReal: true as const, text: "Next", isCurrent: false, setActive: async () => {} },
      links: [
        { isReal: true as const, text: "1", isCurrent: true, setActive: async () => {} },
        { isReal: false as const, text: "…" },
        { isReal: true as const, text: "5", isCurrent: false, setActive: async () => {} },
      ],
    };

    await render(<template><Pagination @links={{links}} /></template>);

    assert.dom("button[aria-current='page']").hasText("1");
    assert.dom(".nvp__pagination__gap").exists({ count: 1 });
    assert.dom("[data-rel='next']").isEnabled();
  });
});

module("pageLinks", function () {
  test("keeps the first, the last, and a window around the current page", function (assert) {
    const links = pageLinks(10, 20, () => {}, { window: 1 });

    assert.deepEqual(
      links.links.map((link) => link.text),
      ["1", "…", "9", "10", "11", "…", "20"],
    );
    assert.strictEqual(links.prev?.text, "Previous");
    assert.strictEqual(links.next?.text, "Next");
    assert.strictEqual(links.first?.text, "First");
    assert.strictEqual(links.last?.text, "Last");
  });

  test("a single page has no prev or next", function (assert) {
    const links = pageLinks(1, 1, () => {});

    assert.deepEqual(
      links.links.map((link) => link.text),
      ["1"],
    );
    assert.strictEqual(links.prev, null);
    assert.strictEqual(links.next, null);
  });
});
