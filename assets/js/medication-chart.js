import Chart from "chart.js/auto";

const MedicationChart = {
  mounted() {
    console.log("mounted", Chart, this.el);

    const _this = this;

    this.pushEvent("fill-medication-chart", {}, (reply, ref) => {
      const data = reply.data;

      _this.medicationChart = new Chart(_this.el, {
        type: "bar",
        options: {
          parsing: {
            xAxisKey: 'date',
            yAxisKey: 'count',
          },
        },
        data: {
          datasets: data.map(med => {
            return {
              label: med.name,
              data: med.counts,
            };
          }),
        },
      });
    });
  },
  destroyed() {
    console.log("destroyed", this.medicationChart);

    this.medicationChart && this.medicationChart.destroy();
  },
};

export default MedicationChart;
