# Pagination

Page controls: first, previous, a row of page buttons, next, last. The current page is marked with `aria-current`.

The controls never move. The four edge buttons are always rendered, disabled at the ends. The row of page buttons has a fixed number of slots that slides with the current page but never changes size. A slot for a page that exists but cannot be moved to yet is a disabled button.

The component renders a `links` object and never fetches anything. That object has the shape WarpDrive's `<EachLink>` yields, so a WarpDrive collection needs no glue, and anything else can build the same shape with `pageLinks`.

```gjs live no-shadow
import { pageLinks, Pagination } from "nvp.ui/pagination";
import { tracked } from "@glimmer/tracking";
import Component from "@glimmer/component";

export default class Demo extends Component {
  @tracked page = 1;

  get links() {
    return pageLinks(this.page, 12, (page) => (this.page = page));
  }

  <template>
    <p>Page {{this.page}} of 12</p>
    <Pagination @links={{this.links}} />
  </template>
}
```

## With WarpDrive

`<Paginate>` yields the pagination state for a request, and `<EachLink>` turns it into links. Pass them straight through.

```gjs
import { Paginate, EachLink } from "@warp-drive/ember/experiments";
import { Pagination } from "nvp.ui/pagination";

<template>
  <Paginate @request={{@links}} as |pages|>
    <EachLink @pages={{pages}} as |links|>
      <Pagination @links={{links}} />
    </EachLink>
  </Paginate>
</template>
```

## API Reference

### Arguments

| Argument     | Type              |                                                     |
| ------------ | ----------------- | --------------------------------------------------- |
| `@links`     | `PaginationLinks` | the pages to offer, see below                       |
| `@pageSlots` | `number`          | how many page buttons to show, default 5            |
| `@label`     | `string`          | the `<nav>`'s accessible name, default "Pagination" |

### `PaginationLinks`

```ts
interface PaginationLinks {
  prev: RealPageLink | null;
  next: RealPageLink | null;
  first?: RealPageLink | null;
  last?: RealPageLink | null;
  links: Array<RealPageLink | PlaceholderPageLink>;
}

interface RealPageLink {
  isReal: true;
  text: string;
  isCurrent: boolean;
  setActive: () => unknown;
}

interface PlaceholderPageLink {
  isReal: false;
  text: string;
  // the first and last page number the placeholder stands for
  indexRange?: [number, number];
}
```

WarpDrive lists the loaded pages as real links and the rest as placeholders with an `indexRange`. The component reads the current page and the total from them, so the row is complete from the first render.

### `pageLinks(current, total, goTo)`

Builds `PaginationLinks` from a page number and a total. Every page is a link.

### `pageSlots(links, count)`

The window of pages the component shows: `count` consecutive pages around the current one, clamped to the collection. Exported for tests and for custom markup.

### Classes & Attributes

| Selector                |                                                              |
| ----------------------- | ------------------------------------------------------------ |
| `[data-rel="first"]`    | the first control, a `<button>`, disabled on the first page  |
| `[data-rel="prev"]`     | the previous control, likewise                               |
| `[data-rel="next"]`     | the next control, disabled on the last page                  |
| `[data-rel="last"]`     | the last control, likewise                                   |
| `[data-page]`           | a page button, disabled when the page cannot be moved to yet |
| `[aria-current="page"]` | the current page's button                                    |

## Installation

```bash
pnpm add nvp.ui
```
