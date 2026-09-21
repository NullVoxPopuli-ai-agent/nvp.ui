import "./variables.css";
import "./focus.css";
import "./pagination.css";

import { fn } from "@ember/helper";
import { on } from "@ember/modifier";

import { pageLinks, pageSlots } from "./-private/page-links.ts";

import type { PaginationLinks, RealPageLink } from "./-private/page-links.ts";
import type { TOC } from "@ember/component/template-only";

export { pageLinks, pageSlots };

function activate(link: RealPageLink) {
  void link.setActive();
}

/**
 * An edge control is disabled when there is nowhere to go: no link,
 * or a link to the page that is already shown.
 */
function isEdgeDisabled(link: RealPageLink | null | undefined) {
  return !link || link.isCurrent;
}

function slotsOf(links: PaginationLinks, count: number | undefined) {
  return pageSlots(links, count ?? 5);
}

interface EdgeSignature {
  Args: {
    link: RealPageLink | null | undefined;
    rel: "first" | "prev" | "next" | "last";
    label: string;
    symbol: string;
  };
}

/**
 * First, previous, next, last. Always rendered, so they never move.
 */
const Edge: TOC<EdgeSignature> = <template>
  <li>
    {{#if (isEdgeDisabled @link)}}
      <button type="button" class="nvp__pagination__link" data-rel={{@rel}} disabled>
        <span aria-hidden="true">{{@symbol}}</span>
        <span class="nvp__pagination__label">{{@label}}</span>
      </button>
    {{else}}
      <button
        type="button"
        class="nvp__pagination__link"
        data-rel={{@rel}}
        {{! @glint-expect-error the branch above narrows @link, glint cannot see it }}
        {{on "click" (fn activate @link)}}
      >
        <span aria-hidden="true">{{@symbol}}</span>
        <span class="nvp__pagination__label">{{@label}}</span>
      </button>
    {{/if}}
  </li>
</template>;

export interface Signature {
  /**
   * The `<nav>` around the controls.
   */
  Element: HTMLElement;
  Args: {
    /**
     * The pages to offer. Pass WarpDrive's links straight through:
     *
     * ```gjs
     * <Paginate @request={{request}} as |pages|>
     *   <EachLink @pages={{pages}} as |links|>
     *     <Pagination @links={{links}} />
     *   </EachLink>
     * </Paginate>
     * ```
     */
    links: PaginationLinks;
    /**
     * How many page buttons to show. The row keeps this many slots
     * as the current page moves, so the buttons stay put.
     *
     * Default: 5
     */
    pageSlots?: number;
    /**
     * The accessible name of the `<nav>`.
     *
     * Default: "Pagination"
     */
    label?: string;
  };
}

export const Pagination: TOC<Signature> = <template>
  <nav class="nvp__pagination" aria-label={{if @label @label "Pagination"}} ...attributes>
    <ul class="nvp__pagination__list">
      <Edge @link={{@links.first}} @rel="first" @label="First" @symbol="«" />
      <Edge @link={{@links.prev}} @rel="prev" @label="Previous" @symbol="‹" />

      {{#each (slotsOf @links @pageSlots) key="page" as |slot|}}
        <li>
          {{#if slot.link}}
            <button
              type="button"
              class="nvp__pagination__link"
              data-page={{slot.page}}
              aria-current={{if slot.isCurrent "page"}}
              {{on "click" (fn activate slot.link)}}
            >
              {{slot.page}}
            </button>
          {{else}}
            <button type="button" class="nvp__pagination__link" data-page={{slot.page}} disabled>
              {{slot.page}}
            </button>
          {{/if}}
        </li>
      {{/each}}

      <Edge @link={{@links.next}} @rel="next" @label="Next" @symbol="›" />
      <Edge @link={{@links.last}} @rel="last" @label="Last" @symbol="»" />
    </ul>
  </nav>
</template>;

export default Pagination;
