import { click, render } from "@ember/test-helpers";
import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";

import { Table } from "#src/index.ts";

const rows = [
  { name: "Apple", count: 3 },
  { name: "Banana", count: 12 },
];

module("Table", function (hooks) {
  setupRenderingTest(hooks);

  test("renders a head, rows, cells, and a hidden caption", async function (assert) {
    await render(
      <template>
        <Table @caption="Fruit">
          <:head as |h|>
            <h.Cell>Name</h.Cell>
            <h.Cell @align="end">Count</h.Cell>
          </:head>
          <:body as |b|>
            {{#each rows as |row|}}
              <b.Row as |r|>
                <r.Cell>{{row.name}}</r.Cell>
              </b.Row>
            {{/each}}
          </:body>
        </Table>
      </template>,
    );

    assert.dom("table").exists();
    assert.dom("caption").hasText("Fruit");
    assert.dom("caption").hasClass("nvp__table__caption--hidden");
    assert.dom("thead th").exists({ count: 2 });
    assert.dom("thead th:nth-child(2)").hasAttribute("data-align", "end");
    assert.dom("tbody tr").exists({ count: 2 });
  });

  test("rows yield cells and an actions cell", async function (assert) {
    await render(
      <template>
        <Table>
          <:body as |b|>
            {{#each rows as |row|}}
              <b.Row as |r|>
                <r.Cell @nowrap={{true}}>{{row.name}}</r.Cell>
                <r.Cell @align="end">{{row.count}}</r.Cell>
                <r.Actions><button type="button">Edit</button></r.Actions>
              </b.Row>
            {{/each}}
          </:body>
        </Table>
      </template>,
    );

    assert.dom("tbody tr:first-child td").exists({ count: 3 });
    assert.dom("tbody tr:first-child td:first-child").hasAttribute("data-nowrap");
    assert.dom("tbody tr:first-child td:nth-child(2)").hasAttribute("data-align", "end");
    assert.dom("tbody tr:first-child td:nth-child(3)").hasClass("nvp__table__actions");
    assert.dom("tbody tr:first-child td:nth-child(3) button").hasText("Edit");
  });

  test("a sortable header is a button with aria-sort", async function (assert) {
    const onSort = () => assert.step("sort");

    await render(
      <template>
        <Table>
          <:head as |h|>
            <h.Cell @sort="ascending" @onSort={{onSort}}>Name</h.Cell>
            <h.Cell>Count</h.Cell>
          </:head>
        </Table>
      </template>,
    );

    assert.dom("th:first-child").hasAttribute("aria-sort", "ascending");
    assert.dom("th:first-child button").exists();
    assert.dom("th:nth-child(2)").doesNotHaveAttribute("aria-sort");
    assert.dom("th:nth-child(2) button").doesNotExist();

    await click("th:first-child button");

    assert.verifySteps(["sort"]);
  });

  test("@isEmpty shows the empty block instead of rows", async function (assert) {
    await render(
      <template>
        <Table @isEmpty={{true}}>
          <:head as |h|>
            <h.Cell>Name</h.Cell>
          </:head>
          <:body as |b|>
            <b.Row as |r|>
              <r.Cell>never</r.Cell>
            </b.Row>
          </:body>
          <:empty>Nothing here yet.</:empty>
        </Table>
      </template>,
    );

    assert.dom("tbody").doesNotExist();
    assert.dom(".nvp__table__empty").hasText("Nothing here yet.");
    assert.dom(".nvp__table").hasAttribute("data-empty");
  });

  test("the footer block renders below the table", async function (assert) {
    await render(
      <template>
        <Table @dense={{true}} @striped={{true}} @stickyHeader={{true}}>
          <:body as |b|>
            <b.Row as |r|>
              <r.Cell>one</r.Cell>
            </b.Row>
          </:body>
          <:footer>Page 1 of 3</:footer>
        </Table>
      </template>,
    );

    assert.dom(".nvp__table__footer").hasText("Page 1 of 3");
    assert.dom(".nvp__table").hasAttribute("data-dense");
    assert.dom(".nvp__table").hasAttribute("data-striped");
    assert.dom(".nvp__table").hasAttribute("data-sticky-header");
  });
});
