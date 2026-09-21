/**
 * A page the user can move to.
 *
 * This is the shape WarpDrive's `PaginationLinks` yields from
 * `<EachLink>`: its `RealPaginationLink` and `RelationalPaginationLink`
 * satisfy `RealPageLink`, and its `PlaceholderPaginationLink` satisfies
 * `PlaceholderPageLink`. Any other source can build the same objects.
 */
export interface RealPageLink {
  readonly isReal: true;
  /** what the control shows, usually the page number */
  readonly text: string;
  readonly isCurrent: boolean;
  /** moves to the page */
  readonly setActive: () => unknown;
}

/**
 * A gap between pages that are shown, rendered as an ellipsis.
 */
export interface PlaceholderPageLink {
  readonly isReal: false;
  readonly text: string;
}

export type PageLink = RealPageLink | PlaceholderPageLink;

export interface PaginationLinks {
  readonly prev: RealPageLink | null;
  readonly next: RealPageLink | null;
  readonly first?: RealPageLink | null;
  readonly last?: RealPageLink | null;
  /** the numbered pages, with placeholders for gaps */
  readonly links: readonly PageLink[];
}

/**
 * Builds `PaginationLinks` from a page number and a total, for callers
 * without WarpDrive. Pages farther than `window` from the current one
 * collapse into a placeholder, with the first and last page always shown.
 */
export function pageLinks(
  current: number,
  total: number,
  goTo: (page: number) => unknown,
  options: { window?: number } = {},
): PaginationLinks {
  const window = options.window ?? 2;
  const real = (page: number): RealPageLink => ({
    isReal: true,
    text: String(page),
    isCurrent: page === current,
    setActive: () => goTo(page),
  });
  const links: PageLink[] = [];
  let gap = false;

  for (let page = 1; page <= total; page++) {
    const shown = page === 1 || page === total || Math.abs(page - current) <= window;

    if (shown) {
      links.push(real(page));
      gap = false;
    } else if (!gap) {
      links.push({ isReal: false, text: "…" });
      gap = true;
    }
  }

  return {
    prev: current > 1 ? { ...real(current - 1), text: "Previous" } : null,
    next: current < total ? { ...real(current + 1), text: "Next" } : null,
    first: current > 1 ? { ...real(1), text: "First" } : null,
    last: current < total ? { ...real(total), text: "Last" } : null,
    links,
  };
}
