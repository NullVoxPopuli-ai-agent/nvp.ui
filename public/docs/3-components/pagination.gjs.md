# Pagination

Page controls: previous, numbered pages with gaps collapsed to an ellipsis, and next. The current page is marked with `aria-current`.

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

| Argument | Type              |                                                     |
| -------- | ----------------- | --------------------------------------------------- |
| `@links` | `PaginationLinks` | the pages to offer, see below                       |
| `@label` | `string`          | the `<nav>`'s accessible name, default "Pagination" |

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
}
```

### `pageLinks(current, total, goTo, { window })`

Builds `PaginationLinks` from a page number and a total. Pages farther than `window` (default 2) from the current page collapse into a placeholder; the first and last page always show.

### Classes & Attributes

| Selector                |                                                                             |
| ----------------------- | --------------------------------------------------------------------------- |
| `[data-rel="prev"]`     | the previous control, a `<button>`, disabled when there is no previous page |
| `[data-rel="next"]`     | the next control, likewise                                                  |
| `[aria-current="page"]` | the current page's button                                                   |
| `.nvp__pagination__gap` | an ellipsis, `aria-hidden`                                                  |

## Installation

```bash
pnpm add nvp.ui
```
