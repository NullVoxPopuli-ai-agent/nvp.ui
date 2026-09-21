# Table

A styled data table on top of [`@universal-ember/table`](https://github.com/universal-ember/table), which supplies the accessible structure, the column and row model, and the plugins. Columns are configuration; rows come from data. The table scrolls sideways on narrow screens instead of squashing its columns.

```gjs live no-shadow
import { Table } from "nvp.ui/table";
import { Button } from "nvp.ui/button";

const fruit = [
  { name: "Apple", count: 3, added: "Aug 1, 2026" },
  { name: "Banana", count: 12, added: "Aug 9, 2026" },
  { name: "Cherry", count: 140, added: "Sep 2, 2026" },
];

const Actions = <template>
  <Button>Edit</Button>
  <Button @variant="danger">Delete</Button>
</template>;

const columns = [
  { key: "name", name: "Name" },
  { key: "count", name: "Count", align: "end" },
  { key: "added", name: "Added", nowrap: true },
  { key: "actions", name: "Actions", align: "end", Cell: Actions },
];

<template>
  <Table @caption="Fruit in stock" @columns={{columns}} @data={{fruit}} @striped={{true}}>
    <:footer>3 of 3 shown</:footer>
  </Table>
</template>
```

## Columns

Each column is a `@universal-ember/table` column config plus layout:

| Key            |                                                                        |
| -------------- | ---------------------------------------------------------------------- |
| `key`          | the property read from each row, and the default sort key              |
| `name`         | the header text                                                        |
| `value`        | `({ row, column }) => value`, when the cell is not the property        |
| `Cell`         | a component receiving `@row` and `@column`, when the cell needs markup |
| `align`        | `start`, `center`, or `end`                                            |
| `nowrap`       | keep the cells on one line                                             |
| `sortable`     | with `@onSort`, `false` opts the column out                            |
| `sortProperty` | the sort key sent to `@onSort`, when it differs from `key`             |

Any other key is kept on the config, so a `Cell` can read it from `@column.config`.

## Sorting

Give the table `@sorts` and `@onSort`, and the headers become buttons with `aria-sort`. The table does not sort the rows; the owner does, in response to `@onSort`, which comes from the `DataSorting` plugin.

```gjs live no-shadow
import { Table } from "nvp.ui/table";
import { tracked } from "@glimmer/tracking";
import Component from "@glimmer/component";

const fruit = [
  { name: "Apple", count: 3 },
  { name: "Banana", count: 12 },
  { name: "Cherry", count: 140 },
];

const columns = [
  { key: "name", name: "Name", sortable: false },
  { key: "count", name: "Count", align: "end" },
];

export default class Demo extends Component {
  @tracked sorts = [];

  get rows() {
    const [sort] = this.sorts;

    if (!sort) return fruit;

    const sorted = [...fruit].sort((a, b) => a[sort.property] - b[sort.property]);

    return sort.direction === "ascending" ? sorted : sorted.reverse();
  }

  onSort = (sorts) => {
    this.sorts = sorts;
  };

  <template>
    <Table
      @columns={{columns}}
      @data={{this.rows}}
      @sorts={{this.sorts}}
      @onSort={{this.onSort}}
      @dense={{true}}
    />
  </template>
}
```

## Rows with a detail

The `afterRow` block renders after every row, inside the body, with the row and the column count. Use it for an expanded detail or an inline editor.

```gjs live no-shadow
import { Table } from "nvp.ui/table";

const fruit = [
  { name: "Apple", count: 3, note: "Crisp." },
  { name: "Banana", count: 12, note: "Bruises easily." },
];

const columns = [
  { key: "name", name: "Name" },
  { key: "count", name: "Count", align: "end" },
];

<template>
  <Table @columns={{columns}} @data={{fruit}}>
    <:afterRow as |row count|>
      <tr><td colspan={{count}}><em>{{row.data.note}}</em></td></tr>
    </:afterRow>
  </Table>
</template>
```

## Empty

With no data, the rows are not rendered and the `empty` block takes their place. The header stays, so the columns are still visible.

```gjs live no-shadow
import { Table } from "nvp.ui/table";

const columns = [
  { key: "name", name: "Name" },
  { key: "count", name: "Count" },
];
const none = [];

<template>
  <Table @columns={{columns}} @data={{none}}>
    <:empty>No fruit yet. Add some above.</:empty>
  </Table>
</template>
```

## API Reference

### Arguments

| Argument        | Type            |                                                     |
| --------------- | --------------- | --------------------------------------------------- |
| `@columns`      | `TableColumn[]` | see Columns                                         |
| `@data`         | `T[]`           | one row per item                                    |
| `@caption`      | `string`        | the accessible name, rendered as a `<caption>`      |
| `@showCaption`  | `boolean`       | show the caption instead of hiding it visually      |
| `@dense`        | `boolean`       | tighter cell padding                                |
| `@striped`      | `boolean`       | alternate row backgrounds                           |
| `@stickyHeader` | `boolean`       | keep the header row in view while the table scrolls |
| `@sorts`        | `SortItem[]`    | the current sort                                    |
| `@onSort`       | `function`      | receives the next sort; makes the headers sortable  |

### Blocks

| Block       | Yields         |                                 |
| ----------- | -------------- | ------------------------------- |
| `:afterRow` | `row`, `count` | after each row, inside the body |
| `:empty`    |                | shown when there is no data     |
| `:footer`   |                | below the table                 |

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
