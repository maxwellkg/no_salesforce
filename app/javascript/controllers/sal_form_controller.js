import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static values = {
    forceMonth: Boolean
  }

  connect() {
    this.forceMonthDimension();
  } 

  forceMonthDimension() {
    let selectedDateRange = document.getElementById('month-date-window').value;

    if (this.forceMonthValue) {
      let columnOption = document.getElementById('sb-select-cols');

      let opts = columnOption.options;

      if (selectedDateRange != 'lm') {
        // select month in the columns dimension and disable the selection

        columnOption.value = 'month'

        for (let i = 0; i < opts.length; i++) {
          if (opts[i].value != 'month') {
            opts[i].disabled = true;
          }
        }
      } else {
        for (let i = 0; i < opts.length; i++) {
          opts[i].disabled = false;
        }
      }
    }
  }

  rowSelection() {
    return document.getElementById('sb-select-rows').value;
  }

  hasRows() {
    return this.rowSelection().length != 0
  }

  colSelection() {
    return document.getElementById('sb-select-cols').value;
  }

  hasCols() {
    return this.colSelection().length != 0
  }

  updateShowValuesAs(event) {
    // No Calculation is always allowed
    let enabledOptions = ['no_calculation'];

    // check to see which dimensions are input
    if (!this.hasRows() && !this.hasCols()) {
      // No calculation only
    } else if (this.hasRows() && !this.hasCols()) {
      // No calc, pct of col
      enabledOptions.push('pct_of_column_total');
    } else if (!this.hasRows() && this.hasCols()) {
      // no calc, pct of row
      enabledOptions.push('pct_of_row_total');
    } else if (this.hasRows() && this.hasCols()) {
      // all options valid
      // no calc, pct of row, pct of col, pct of grand total
      ['pct_of_row_total', 'pct_of_column_total', 'pct_of_grand_total'].forEach(opt => {
        enabledOptions.push(opt);
      })
    }

    document.querySelectorAll('#show-values-as option').forEach(opt => {
      if (enabledOptions.includes(opt.value)) {
        opt.disabled = false;
      } else {
        opt.disabled = true;
      }
    })

    // if the current selection is no longer valid, set back to no calculation
    let selectedOption = document.getElementById('show-values-as');

    if (!(selectedOption.value in enabledOptions)) {
      selectedOption.value = 'no_calculation';
    }
  }

  changeMode() {
    let mode = document.querySelector('input[name="mode"]:checked');
    let url = `${this.urlValue}?mode=${mode}`

    return get(url, { responseKind: 'turbo_stream' });
  }
}
