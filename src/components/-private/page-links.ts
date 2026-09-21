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
 * Pages that are known to exist but cannot be moved to yet.
 */
export interface PlaceholderPageLink {
  readonly isReal: false;
  readonly text: string;
  /** the first and last page number the placeholder stands for */
  readonly indexRange?: readonly [number, number];
}

export type PageLink = RealPageLink | PlaceholderPageLink;

export interface PaginationLinks {
  readonly prev: RealPageLink | null;
  readonly next: RealPageLink | null;
  readonly first?: RealPageLink | null;
  readonly last?: RealPageLink | null;
  /** the numbered pages, with placeholders for pages not yet loaded */
  readonly links: readonly PageLink[];
}

/**
 * One position in the row of page buttons. The row has a constant
 * number of slots, so the buttons never move between clicks. A slot
 * without a link is a page that exists but cannot be moved to.
 */
export interface PageSlot {
  readonly page: number;
  readonly link: RealPageLink | null;
  readonly isCurrent: boolean;
}

function pageNumberOf(link: RealPageLink) {
  const page = Number(link.text);

  return Number.isInteger(page) && page > 0 ? page : null;
}

/**
 * The window of pages to show as buttons: `count` consecutive pages
 * around the current one, clamped to the collection. The window
 * slides as the current page changes, but its size does not.
 *
 * Empty when the links carry no page numbers, as with cursors.
 */
export function pageSlots(links: PaginationLinks, count: number): PageSlot[] {
  const byPage = new Map<number, RealPageLink>();
  let current: number | null = null;
  let total = 0;

  for (const link of links.links) {
    if (link.isReal) {
      const page = pageNumberOf(link);

      if (page === null) continue;

      byPage.set(page, link);
      total = Math.max(total, page);

      if (link.isCurrent) current = page;
    } else if (link.indexRange) {
      total = Math.max(total, link.indexRange[1]);
    }
  }

  if (current === null || total === 0) return [];

  const size = Math.min(count, total);
  const start = Math.max(1, Math.min(current - Math.floor(size / 2), total - size + 1));
  const slots: PageSlot[] = [];

  for (let page = start; page < start + size; page++) {
    slots.push({ page, link: byPage.get(page) ?? null, isCurrent: page === current });
  }

  return slots;
}

/**
 * Builds `PaginationLinks` from a page number and a total, for callers
 * without WarpDrive. Every page is a link.
 */
export function pageLinks(
  current: number,
  total: number,
  goTo: (page: number) => unknown,
): PaginationLinks {
  const real = (page: number): RealPageLink => ({
    isReal: true,
    text: String(page),
    isCurrent: page === current,
    setActive: () => goTo(page),
  });
  const links: RealPageLink[] = [];

  for (let page = 1; page <= total; page++) {
    links.push(real(page));
  }

  return {
    prev: current > 1 ? { ...real(current - 1), text: "Previous" } : null,
    next: current < total ? { ...real(current + 1), text: "Next" } : null,
    first: current > 1 ? { ...real(1), text: "First" } : null,
    last: current < total ? { ...real(total), text: "Last" } : null,
    links,
  };
}
