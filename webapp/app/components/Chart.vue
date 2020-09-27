<template lang="pug">
  v-flex
    apexcharts(height="350" :options="chartOptions" :series="chartData.series")
</template>

<script>
export default {
  props: {
    chartData: {
      type: Object,
      default: () => ({
        series: [],
        xTickLabels: [],
        colors: []
      })
    }
  },
  data() {
    return {
      chartOptions: {
        chart: {
          type: 'line'
        },
        colors: this.chartData.colors,
        xaxis: {
          categories: this.chartData.xTickLabels
        }
      }
    }
  }
}
</script>
