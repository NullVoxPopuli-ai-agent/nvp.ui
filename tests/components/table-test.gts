import { click, render } from "@ember/test-helpers";
import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";

import { Table } from "#src/index.ts";

import type { TOC } from "@ember/component/template-only";
import type { CellSignature, SortItem, TableColumn } from "#src/index.ts";

interface Fruit {
  name: string;
  count: number;
}

const rows: Fruit[] = [
  { name: "Apple", count: 3 },
  { name: "Banana", count: 12 },
];

const CountCell: TOC<CellSignature<Fruit>> = <template>
  <strong>{{@row.data.count}}</strong>
</template>;

const columns: TableColumn<Fruit>[] = [
  { key: "name", name: "Name" },
  { key: "count", name: "Count", align: "end", nowrap: true, Cell: CountCell },
];

module("Table", function (hooks) {
  setupRenderingTest(hooks);

  test("renders a head, rows, cells, and a hidden caption", async function (assert) {
    await render(
      <template><Table @caption="Fruit" @columns={{columns}} @data={{rows}} /></template>,
    );

    assert.dom("table").exists();
    assert.dom("caption").hasText("Fruit");
    assert.dom("caption").hasClass("nvp__table__caption--hidden");
    assert.dom("thead th").exists({ count: 2 });
    assert.dom("thead th:nth-child(1)").hasText("Name");
    assert.dom("thead th:nth-child(2)").hasAttribute("data-align", "end");
    assert.dom("tbody tr").exists({ count: 2 });
    assert.dom("tbody tr:first-child td:first-child").hasText("Apple");
  });

  test("a column with a Cell renders it; the rest render the value", async function (assert) {
    await render(<template><Table @columns={{columns}} @data={{rows}} /></template>);

    assert.dom("tbody tr:first-child td:nth-child(2) strong").hasText("3");
    assert.dom("tbody tr:first-child td:nth-child(2)").hasAttribute("data-align", "end");
    assert.dom("tbody tr:first-child td:nth-child(2)").hasAttribute("data-nowrap");
    assert.dom("tbody tr:first-child td:first-child strong").doesNotExist();
  });

  test("with @onSort, headers sort and carry aria-sort", async function (assert) {
    const sorts: SortItem<Fruit>[] = [];
    const onSort = (next: SortItem<Fruit>[]) =>
      assert.step(next.map((s) => `${s.property}:${s.direction}`).join(",") || "none");

    await render(
      <template>
        <Table @columns={{columns}} @data={{rows}} @sorts={{sorts}} @onSort={{onSort}} />
      </template>,
    );

    assert.dom("th:first-child").hasAttribute("aria-sort", "none");
    assert.dom("th:first-child button").exists();

    await click("th:first-child button");

    assert.verifySteps(["name:descending"]);
  });

  test("without @onSort, headers are plain text", async function (assert) {
    await render(<template><Table @columns={{columns}} @data={{rows}} /></template>);

    assert.dom("th button").doesNotExist();
  });

  test("a column can opt out of sorting", async function (assert) {
    const fixed: TableColumn<Fruit>[] = [
      { key: "name", name: "Name", sortable: false },
      { key: "count", name: "Count" },
    ];
    const onSort = () => {};

    await render(
      <template><Table @columns={{fixed}} @data={{rows}} @onSort={{onSort}} /></template>,
    );

    assert.dom("th:first-child button").doesNotExist();
    assert.dom("th:nth-child(2) button").exists();
  });

  test("no data shows the empty block instead of rows", async function (assert) {
    const none: Fruit[] = [];

    await render(
      <template>
        <Table @columns={{columns}} @data={{none}}>
          <:empty>Nothing here yet.</:empty>
        </Table>
      </template>,
    );

    assert.dom("thead th").exists({ count: 2 });
    assert.dom("tbody").doesNotExist();
    assert.dom(".nvp__table__empty").hasText("Nothing here yet.");
    assert.dom(".nvp__table").hasAttribute("data-empty");
  });

  test("the footer block renders below the table", async function (assert) {
    await render(
      <template>
        <Table @columns={{columns}} @data={{rows}} @dense={{true}}>
          <:footer>Page 1 of 3</:footer>
        </Table>
      </template>,
    );

    assert.dom(".nvp__table__footer").hasText("Page 1 of 3");
    assert.dom(".nvp__table").hasAttribute("data-dense");
  });
});
