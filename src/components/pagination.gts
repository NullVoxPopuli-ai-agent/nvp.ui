import "./variables.css";
import "./focus.css";
import "./pagination.css";

import { withQP } from "ember-primitives/qp";

import { pageSlots } from "./-private/page-slots.ts";

import type { TOC } from "@ember/component/template-only";

export { pageSlots };

function paramOf(param: string | undefined) {
  return param ?? "page";
}

function slotsOf(page: number, totalPages: number, count: number | undefined) {
  return pageSlots(page, totalPages, count ?? 5);
}

function asString(page: number) {
  return String(page);
}

function isCurrent(page: number, current: number) {
  return page === current;
}

function before(page: number) {
  return page - 1;
}

function after(page: number) {
  return page + 1;
}

interface EdgeSignature {
  Args: {
    rel: "first" | "prev" | "next" | "last";
    page: number;
    param: string;
    label: string;
    symbol: string;
    /**
     * Whether the symbol comes after the label.
     *
     * Forward controls point right, so their symbol trails.
     */
    symbolAfter?: boolean;
    disabled: boolean;
  };
}

/**
 * First, previous, next, last.
 *
 * Always rendered, so the row never changes shape.
 * At the ends, the control is a link without an href,
 * which is how HTML spells a link that goes nowhere.
 */
const Edge: TOC<EdgeSignature> = <template>
  <li>
    {{#if @disabled}}
      <a class="nvp__pagination__link" data-rel={{@rel}} role="link" aria-disabled="true">
        {{#if @symbolAfter}}
          <span class="nvp__pagination__label">{{@label}}</span>
          <span aria-hidden="true">{{@symbol}}</span>
        {{else}}
          <span aria-hidden="true">{{@symbol}}</span>
          <span class="nvp__pagination__label">{{@label}}</span>
        {{/if}}
      </a>
    {{else}}
      <a class="nvp__pagination__link" data-rel={{@rel}} href={{withQP @param (asString @page)}}>
        {{#if @symbolAfter}}
          <span class="nvp__pagination__label">{{@label}}</span>
          <span aria-hidden="true">{{@symbol}}</span>
        {{else}}
          <span aria-hidden="true">{{@symbol}}</span>
          <span class="nvp__pagination__label">{{@label}}</span>
        {{/if}}
      </a>
    {{/if}}
  </li>
</template>;

export interface Signature {
  /**
   * The `<nav>` around the links.
   */
  Element: HTMLElement;
  Args: {
    /**
     * The page being shown, counted from 1.
     */
    page: number;
    totalPages: number;
    /**
     * The query param that holds the page number.
     *
     * Every link keeps the current URL's query params
     * and sets this one.
     *
     * Default: "page"
     */
    param?: string;
    /**
     * How many page links to show.
     *
     * The row keeps this many as the current page moves,
     * so the links stay put.
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

/**
 * Page links, driven by the router.
 *
 * Each link is a plain anchor whose href is the current URL
 * with the page query param set.
 * The router is the click handler.
 *
 * The app must:
 * - hand anchor clicks to the router, with `properLinks`
 *   from `ember-primitives/proper-links`
 * - declare the query param on the route that reads it
 *
 * The layout never changes shape as the page changes:
 * - first, previous, next and last are always rendered
 * - the page links are a fixed number of slots around the current page
 */
export const Pagination: TOC<Signature> = <template>
  <nav class="nvp__pagination" aria-label={{if @label @label "Pagination"}} ...attributes>
    {{#let (paramOf @param) as |param|}}
      <ul class="nvp__pagination__list">
        <Edge
          @rel="first"
          @page={{1}}
          @param={{param}}
          @label="First"
          @symbol="«"
          @disabled={{isCurrent @page 1}}
        />
        <Edge
          @rel="prev"
          @page={{before @page}}
          @param={{param}}
          @label="Previous"
          @symbol="‹"
          @disabled={{isCurrent @page 1}}
        />

        {{#each (slotsOf @page @totalPages @pageSlots) as |page|}}
          <li>
            <a
              class="nvp__pagination__link"
              data-page={{page}}
              aria-current={{if (isCurrent page @page) "page"}}
              href={{withQP param (asString page)}}
            >
              {{page}}
            </a>
          </li>
        {{/each}}

        <Edge
          @rel="next"
          @page={{after @page}}
          @param={{param}}
          @label="Next"
          @symbol="›"
          @symbolAfter={{true}}
          @disabled={{isCurrent @page @totalPages}}
        />
        <Edge
          @rel="last"
          @page={{@totalPages}}
          @param={{param}}
          @label="Last"
          @symbol="»"
          @symbolAfter={{true}}
          @disabled={{isCurrent @page @totalPages}}
        />
      </ul>
    {{/let}}
  </nav>
</template>;
