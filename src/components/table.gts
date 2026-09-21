import "./variables.css";
import "./focus.css";
import "./table.css";

import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";

import { headlessTable } from "@universal-ember/table";
import {
  DataSorting,
  isSortable,
  sort,
  sortDirection,
} from "@universal-ember/table/plugins/data-sorting";

import type { ComponentLike } from "@glint/template";
import type { Column, ColumnConfig, Row } from "@universal-ember/table";
import type { SortItem } from "@universal-ember/table/plugins/data-sorting";

export type Align = "start" | "center" | "end";

/**
 * A column.
 *
 * The `@universal-ember/table` config, plus how nvp.ui lays it out:
 * - `key`, `name`, `value`, `Cell` are the upstream config
 * - `align`, `nowrap`, `sortable`, `sortProperty` are layout
 *
 * Extra keys are kept.
 * A `Cell` component reads them from `@column.config`.
 */
export interface TableColumn<T = unknown> extends ColumnConfig<T> {
  /**
   * Text alignment of the column.
   * Numbers usually want `end`.
   *
   * Default: start
   */
  align?: Align;
  /**
   * Keeps the column's cells on one line.
   *
   * For ids, dates, short codes.
   */
  nowrap?: boolean;
  /**
   * Whether the header sorts.
   *
   * Only matters when the table has `@onSort`.
   * Then every column sorts unless it says `false`.
   */
  sortable?: boolean;
  /**
   * The sort key sent to `@onSort`.
   *
   * Only needed when it is not the column `key`.
   */
  sortProperty?: string;
  [extra: string]: unknown;
}

/**
 * The arguments a `Cell` component receives.
 */
export interface CellSignature<T = unknown> {
  Args: {
    column: Column<T>;
    row: Row<T>;
  };
}

export interface Signature<T = unknown> {
  /**
   * The `<table>`.
   */
  Element: HTMLTableElement;
  Args: {
    columns: TableColumn<T>[];
    data: T[];
    /**
     * The table's accessible name, rendered as a `<caption>`.
     *
     * Hidden unless `@showCaption` is set.
     */
    caption?: string;
    showCaption?: boolean;
    /**
     * Tighter row padding.
     */
    dense?: boolean;
    /**
     * The current sort, one entry per sorted column.
     *
     * The owner sorts the data.
     * The table only shows the state and asks for changes.
     */
    sorts?: SortItem<T>[];
    /**
     * Called with the next sort when a header is clicked.
     *
     * Providing this makes the headers sortable.
     */
    onSort?: (sorts: SortItem<T>[]) => void;
  };
  Blocks: {
    /**
     * Shown instead of the rows when there is no data.
     */
    empty: [];
    /**
     * Below the table: pagination, totals, notes.
     */
    footer: [];
  };
}

function layoutOf<T>(column: Column<T>) {
  return column.config as TableColumn<T>;
}

function alignOf<T>(column: Column<T>) {
  return layoutOf(column).align;
}

function nowrapOf<T>(column: Column<T>) {
  return layoutOf(column).nowrap;
}

/**
 * `Cell` is typed loosely upstream.
 * This is what the invocation needs.
 */
function cellOf<T>(column: Column<T>) {
  return column.Cell as unknown as ComponentLike<CellSignature<T>> | undefined;
}

export class Table<T = unknown> extends Component<Signature<T>> {
  table = headlessTable<T>(this, {
    columns: () => this.args.columns.map((column) => this.withSorting(column)),
    data: () => this.args.data,
    plugins: [
      [
        DataSorting,
        () => ({
          sorts: this.args.sorts ?? [],
          onSort: this.args.onSort,
        }),
      ],
    ],
  });

  /**
   * Turns `sortable` and `sortProperty` into the plugin's per-column options.
   *
   * Without `@onSort`, nothing sorts.
   */
  withSorting = (column: TableColumn<T>): ColumnConfig<T> => {
    const isSortable = Boolean(this.args.onSort) && column.sortable !== false;
    const sortingOptions = () => ({
      isSortable,
      sortProperty: column.sortProperty ?? column.key,
    });

    return {
      ...column,
      pluginOptions: [
        ...(column.pluginOptions ?? []),
        [DataSorting, sortingOptions] as unknown as NonNullable<
          ColumnConfig<T>["pluginOptions"]
        >[number],
      ],
    };
  };

  get isEmpty() {
    return this.args.data.length === 0;
  }

  <template>
    <div class="nvp__table" data-dense={{@dense}} data-empty={{this.isEmpty}}>
      <table class="nvp__table__table" {{this.table.modifiers.container}} ...attributes>
        {{#if @caption}}
          <caption
            class={{unless @showCaption "nvp__table__caption--hidden"}}
          >{{@caption}}</caption>
        {{/if}}

        <thead class="nvp__table__head">
          <tr>
            {{#each this.table.columns as |column|}}
              <th
                scope="col"
                class="nvp__table__header-cell"
                data-align={{alignOf column}}
                {{this.table.modifiers.columnHeader column}}
              >
                {{#if (isSortable column)}}
                  <button
                    type="button"
                    class="nvp__table__sort"
                    data-sort={{sortDirection column}}
                    {{on "click" (fn sort column)}}
                  >
                    {{column.name}}
                    <span class="nvp__table__sort-icon" aria-hidden="true"></span>
                  </button>
                {{else}}
                  {{column.name}}
                {{/if}}
              </th>
            {{/each}}
          </tr>
        </thead>

        {{#unless this.isEmpty}}
          <tbody class="nvp__table__body">
            {{#each this.table.rows as |row|}}
              <tr class="nvp__table__row" {{this.table.modifiers.row row}}>
                {{#each this.table.columns as |column|}}
                  <td
                    class="nvp__table__cell"
                    data-align={{alignOf column}}
                    data-nowrap={{nowrapOf column}}
                  >
                    {{#let (cellOf column) as |Cell|}}
                      {{#if Cell}}
                        <Cell @column={{column}} @row={{row}} />
                      {{else}}
                        {{column.getValueForRow row}}
                      {{/if}}
                    {{/let}}
                  </td>
                {{/each}}
              </tr>
            {{/each}}
          </tbody>
        {{/unless}}
      </table>

      {{#if this.isEmpty}}
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
  </template>
}
