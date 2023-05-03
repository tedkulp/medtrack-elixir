import Chart from "chart.js/auto";

const updateChart = (_this, data) => {
  if (!_this.medicationChart) {
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
  } else {
    _this.medicationChart.data.datasets = data.map(med => {
      return {
        label: med.name,
        data: med.counts,
      };
    });
    _this.medicationChart.update();
  }
};

const MedicationChart = {
  mounted() {
    const _this = this;

    this.pushEvent("fill-medication-chart", {}, (reply, ref) => {
      updateChart(_this, reply.data);
    });

    this.handleEvent("update-medication-chart", (reply) => {
      updateChart(_this, reply.data);
    });
  },
  destroyed() {
    this.medicationChart && this.medicationChart.destroy();
  },
};

export default MedicationChart;
