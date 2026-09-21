# Table

A data table with a header row, cells that align and stay on one line, sortable headers, an actions cell, an empty state, and a footer for pagination or totals. On narrow screens the table scrolls sideways instead of squashing its columns.

```gjs live no-shadow
import { Table } from "nvp.ui/table";
import { Button } from "nvp.ui/button";

const fruit = [
  { name: "Apple", count: 3, added: "Aug 1, 2026" },
  { name: "Banana", count: 12, added: "Aug 9, 2026" },
  { name: "Cherry", count: 140, added: "Sep 2, 2026" },
];

<template>
  <Table @caption="Fruit in stock" @striped={{true}}>
    <:head as |h|>
      <h.Cell>Name</h.Cell>
      <h.Cell @align="end">Count</h.Cell>
      <h.Cell>Added</h.Cell>
      <h.Cell @align="end">Actions</h.Cell>
    </:head>
    <:body as |b|>
      {{#each fruit as |row|}}
        <b.Row as |r|>
          <r.Cell>{{row.name}}</r.Cell>
          <r.Cell @align="end">{{row.count}}</r.Cell>
          <r.Cell @nowrap={{true}}>{{row.added}}</r.Cell>
          <r.Actions>
            <Button>Edit</Button>
            <Button @variant="danger">Delete</Button>
          </r.Actions>
        </b.Row>
      {{/each}}
    </:body>
    <:footer>3 of 3 shown</:footer>
  </Table>
</template>
```

## Sorting

A header cell with `@onSort` renders as a button. `@sort` sets `aria-sort` and the arrow. The table does not sort the rows; the owner does, in response to `@onSort`.

```gjs live no-shadow
import { Table } from "nvp.ui/table";
import { tracked } from "@glimmer/tracking";
import Component from "@glimmer/component";

const fruit = [
  { name: "Apple", count: 3 },
  { name: "Banana", count: 12 },
  { name: "Cherry", count: 140 },
];

export default class Demo extends Component {
  @tracked direction = "ascending";

  get rows() {
    const sorted = [...fruit].sort((a, b) => a.count - b.count);

    return this.direction === "ascending" ? sorted : sorted.reverse();
  }

  toggle = () => {
    this.direction = this.direction === "ascending" ? "descending" : "ascending";
  };

  <template>
    <Table @dense={{true}}>
      <:head as |h|>
        <h.Cell>Name</h.Cell>
        <h.Cell @align="end" @sort={{this.direction}} @onSort={{this.toggle}}>Count</h.Cell>
      </:head>
      <:body as |b|>
        {{#each this.rows as |row|}}
          <b.Row as |r|>
            <r.Cell>{{row.name}}</r.Cell>
            <r.Cell @align="end">{{row.count}}</r.Cell>
          </b.Row>
        {{/each}}
      </:body>
    </Table>
  </template>
}
```

## Empty

With `@isEmpty`, the rows are not rendered and the `empty` block takes their place. The header stays, so the columns are still visible.

```gjs live no-shadow
import { Table } from "nvp.ui/table";

<template>
  <Table @isEmpty={{true}}>
    <:head as |h|>
      <h.Cell>Name</h.Cell>
      <h.Cell>Count</h.Cell>
    </:head>
    <:empty>No fruit yet. Add some above.</:empty>
  </Table>
</template>
```

## API Reference

### Arguments

| Argument        | Type      |                                                     |
| --------------- | --------- | --------------------------------------------------- |
| `@caption`      | `string`  | the accessible name, rendered as a `<caption>`      |
| `@showCaption`  | `boolean` | show the caption instead of hiding it visually      |
| `@dense`        | `boolean` | tighter cell padding                                |
| `@striped`      | `boolean` | alternate row backgrounds                           |
| `@stickyHeader` | `boolean` | keep the header row in view while the table scrolls |
| `@isEmpty`      | `boolean` | render the `empty` block instead of the rows        |

### Blocks

| Block     | Yields     |                                                                    |
| --------- | ---------- | ------------------------------------------------------------------ |
| `:head`   | `{ Cell }` | header cells; `Cell` takes `@align`, `@sort`, `@onSort`            |
| `:body`   | `{ Row }`  | `Row` yields `{ Cell, Actions }`; `Cell` takes `@align`, `@nowrap` |
| `:empty`  |            | shown when `@isEmpty`                                              |
| `:footer` |            | below the table                                                    |

### CSS API

| Variable                 |                                     |
| ------------------------ | ----------------------------------- |
| `--table-cell-padding-y` | vertical cell padding               |
| `--table-cell-padding-x` | horizontal cell padding             |
| `--table-border-color`   | row separator color                 |
| `--table-header-color`   | header text color                   |
| `--table-stripe-color`   | even row background with `@striped` |
| `--table-hover-color`    | row background on hover             |

## Installation

```bash
pnpm add nvp.ui
```
