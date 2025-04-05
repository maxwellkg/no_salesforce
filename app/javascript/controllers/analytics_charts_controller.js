import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static selectorTargets = ['lineChartSelector', 'donutChartSelector', 'columnChartSelector', 'stackedColumnChartSelector'];
  static chartTargets = ['lineChart', 'donutChart', 'columnChart', 'stackedColumnChart'];

  static targets = this.selectorTargets.concat(this.chartTargets);

  show(event) {
    // hide the chart that is currently showing
    // we don't track which is visible, so just hide them all

    this.constructor.chartTargets.forEach(function(chartType) {
      const targetName = `${chartType}Target`;
      const capitalizedTargetName = targetName.charAt(0).toUpperCase() + targetName.slice(1);

      // depending on which chart types are valid, not all of the targets
      // may actually be present
      if (this[`has${capitalizedTargetName}`]) {
        this[`${targetName}`].classList.add('hidden');  
      };
    }.bind(this));

    // then show the one in question
    const element = event.target;
    const targetToShow = element.dataset.chartTarget;
    this[`${targetToShow}`].classList.remove('hidden');
  }
}