import "./variables.css";
import "./focus.css";
import "./pagination.css";

import { fn } from "@ember/helper";
import { on } from "@ember/modifier";

import { pageLinks } from "./-private/page-links.ts";

import type { PageLink, PaginationLinks, RealPageLink } from "./-private/page-links.ts";
import type { TOC } from "@ember/component/template-only";

export { pageLinks };

function isReal(link: PageLink): link is RealPageLink {
  return link.isReal;
}

function activate(link: RealPageLink) {
  void link.setActive();
}

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
      <li>
        {{#if @links.prev}}
          <button
            type="button"
            class="nvp__pagination__link"
            data-rel="prev"
            {{on "click" (fn activate @links.prev)}}
          >
            ‹
            <span class="nvp__pagination__label">{{@links.prev.text}}</span>
          </button>
        {{else}}
          <button type="button" class="nvp__pagination__link" data-rel="prev" disabled>
            ‹
            <span class="nvp__pagination__label">Previous</span>
          </button>
        {{/if}}
      </li>

      {{#each @links.links as |link|}}
        <li>
          {{#if (isReal link)}}
            <button
              type="button"
              class="nvp__pagination__link"
              aria-current={{if link.isCurrent "page"}}
              {{on "click" (fn activate link)}}
            >
              {{link.text}}
            </button>
          {{else}}
            <span class="nvp__pagination__gap" aria-hidden="true">{{link.text}}</span>
          {{/if}}
        </li>
      {{/each}}

      <li>
        {{#if @links.next}}
          <button
            type="button"
            class="nvp__pagination__link"
            data-rel="next"
            {{on "click" (fn activate @links.next)}}
          >
            <span class="nvp__pagination__label">{{@links.next.text}}</span>
            ›
          </button>
        {{else}}
          <button type="button" class="nvp__pagination__link" data-rel="next" disabled>
            <span class="nvp__pagination__label">Next</span>
            ›
          </button>
        {{/if}}
      </li>
    </ul>
  </nav>
</template>;

export default Pagination;
