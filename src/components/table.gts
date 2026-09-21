import "./variables.css";
import "./focus.css";
import "./table.css";

import { hash } from "@ember/helper";
import { on } from "@ember/modifier";

import type { TOC } from "@ember/component/template-only";
import type { ComponentLike } from "@glint/template";

export type SortDirection = "ascending" | "descending" | "none";
export type Align = "start" | "center" | "end";

export interface HeaderCellSignature {
  Element: HTMLTableCellElement;
  Args: {
    /**
     * Text alignment of the column. Numbers usually want `end`.
     *
     * Default: start
     */
    align?: Align;
    /**
     * The current sort of this column, set as `aria-sort` on the cell.
     * With `@onSort`, the header becomes a button that asks for the
     * next sort.
     */
    sort?: SortDirection;
    /**
     * Called when the user clicks a sortable header.
     */
    onSort?: () => void;
  };
  Blocks: {
    default: [];
  };
}

export interface CellSignature {
  Element: HTMLTableCellElement;
  Args: {
    align?: Align;
    /**
     * Keeps the content on one line. For ids, dates, and short codes.
     */
    nowrap?: boolean;
  };
  Blocks: {
    default: [];
  };
}

export interface RowSignature {
  Element: HTMLTableRowElement;
  Blocks: {
    default: [
      {
        Cell: ComponentLike<CellSignature>;
        /**
         * A cell for the row's buttons: end-aligned, never wraps.
         */
        Actions: ComponentLike<{ Element: HTMLTableCellElement; Blocks: { default: [] } }>;
      },
    ];
  };
}

export interface Signature {
  /**
   * The `<table>`.
   */
  Element: HTMLTableElement;
  Args: {
    /**
     * The table's accessible name, rendered as a `<caption>`. Hidden
     * unless `@showCaption` is set.
     */
    caption?: string;
    showCaption?: boolean;
    /**
     * Tighter row padding.
     */
    dense?: boolean;
    /**
     * Alternate row backgrounds.
     */
    striped?: boolean;
    /**
     * Keeps the header row in view while the table scrolls.
     */
    stickyHeader?: boolean;
    /**
     * When true, the `empty` block renders in place of the rows.
     */
    isEmpty?: boolean;
  };
  Blocks: {
    /**
     * The header row. Yields the header cell.
     */
    head: [{ Cell: ComponentLike<HeaderCellSignature> }];
    /**
     * The rows. Yields the row component.
     */
    body: [{ Row: ComponentLike<RowSignature> }];
    /**
     * Shown instead of the rows when `@isEmpty` is true.
     */
    empty: [];
    /**
     * Below the table: pagination, totals, notes.
     */
    footer: [];
  };
}

const HeaderCell: TOC<HeaderCellSignature> = <template>
  <th
    scope="col"
    class="nvp__table__header-cell"
    data-align={{@align}}
    aria-sort={{if @sort @sort}}
    ...attributes
  >
    {{#if @onSort}}
      <button type="button" class="nvp__table__sort" data-sort={{@sort}} {{on "click" @onSort}}>
        {{yield}}
        <span class="nvp__table__sort-icon" aria-hidden="true"></span>
      </button>
    {{else}}
      {{yield}}
    {{/if}}
  </th>
</template>;

const Cell: TOC<CellSignature> = <template>
  <td class="nvp__table__cell" data-align={{@align}} data-nowrap={{@nowrap}} ...attributes>
    {{yield}}
  </td>
</template>;

const Actions: TOC<{ Element: HTMLTableCellElement; Blocks: { default: [] } }> = <template>
  <td class="nvp__table__cell nvp__table__actions" ...attributes>
    {{yield}}
  </td>
</template>;

const Row: TOC<RowSignature> = <template>
  <tr class="nvp__table__row" ...attributes>
    {{yield (hash Cell=Cell Actions=Actions)}}
  </tr>
</template>;

export const Table: TOC<Signature> = <template>
  <div
    class="nvp__table"
    data-dense={{@dense}}
    data-striped={{@striped}}
    data-sticky-header={{@stickyHeader}}
    data-empty={{@isEmpty}}
  >
    <div class="nvp__table__scroll">
      <table class="nvp__table__table" ...attributes>
        {{#if @caption}}
          <caption
            class={{unless @showCaption "nvp__table__caption--hidden"}}
          >{{@caption}}</caption>
        {{/if}}

        {{#if (has-block "head")}}
          <thead class="nvp__table__head">
            <tr>
              {{yield (hash Cell=HeaderCell) to="head"}}
            </tr>
          </thead>
        {{/if}}

        {{#unless @isEmpty}}
          <tbody class="nvp__table__body">
            {{yield (hash Row=Row) to="body"}}
          </tbody>
        {{/unless}}
      </table>
    </div>

    {{#if @isEmpty}}
      <div class="nvp__table__empty">
        {{yield to="empty"}}
      </div>
    {{/if}}

    {{#if (has-block "footer")}}
      <div class="nvp__table__footer">
        {{yield to="footer"}}
      </div>
    {{/if}}
  </div>
</template>;

export default Table;
