# Pagination

Page links: first, previous, a row of page numbers, next, last. The current page is marked with `aria-current`.

The links are plain anchors, and the router is the click handler. Each href is the current URL with the page query param set, so every other query param survives a page change. The component needs two things from the app, described under Setup.

The links never move. The four edge links are always rendered, and at the ends they go nowhere. The row of page numbers has a fixed number of slots that slides with the current page but never changes size.

```gjs live no-shadow
import { Pagination } from "nvp.ui/pagination";
import { qp } from "ember-primitives/qp";

const current = (page) => Number(page ?? 1);

<template>
  {{#let (current (qp "page")) as |page|}}
    <p>Page {{page}} of 12</p>
    <Pagination @page={{page}} @totalPages={{12}} />
  {{/let}}
</template>
```

## Setup

The component is only useful with the router. Two things must be in place.

Anchor clicks must reach the router. `properLinks` from ember-primitives does that for every anchor in the app:

```ts
import EmberRouter from "@ember/routing/router";
import { properLinks } from "ember-primitives/proper-links";

@properLinks
export default class Router extends EmberRouter {}
```

The route that shows the pages must declare the query param, so a change re-runs its model:

```ts
export default class LinksRoute extends Route {
  queryParams = {
    page: { refreshModel: true },
  };

  model({ page }) {
    return fetchPage(Number(page ?? 1));
  }
}
```

Then the component only needs the current page and the total:

```gjs
<Pagination @page={{@model.page}} @totalPages={{@model.totalPages}} />
```

## API Reference

### Arguments

| Argument      | Type     |                                                     |
| ------------- | -------- | --------------------------------------------------- |
| `@page`       | `number` | the page being shown, counted from 1                |
| `@totalPages` | `number` | how many pages there are                            |
| `@param`      | `string` | the query param that holds the page, default "page" |
| `@pageSlots`  | `number` | how many page links to show, default 5              |
| `@label`      | `string` | the `<nav>`'s accessible name, default "Pagination" |

### `pageSlots(page, totalPages, count)`

The page numbers the component shows: `count` consecutive pages around the current one, clamped to the collection. Exported for custom markup.

### Classes & Attributes

| Selector                |                                                   |
| ----------------------- | ------------------------------------------------- |
| `[data-rel="first"]`    | the first link, without an href on the first page |
| `[data-rel="prev"]`     | the previous link, likewise                       |
| `[data-rel="next"]`     | the next link, without an href on the last page   |
| `[data-rel="last"]`     | the last link, likewise                           |
| `[data-page]`           | a page link, with the page number                 |
| `[aria-current="page"]` | the current page's link                           |
| `[aria-disabled]`       | an edge link that goes nowhere                    |

## Installation

```bash
pnpm add nvp.ui
```
