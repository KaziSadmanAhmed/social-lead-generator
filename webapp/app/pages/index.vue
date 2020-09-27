<template lang="pug">
  v-layout(column justify-center align-center)
</template>

<script>
export default {
  created() {
    this.$router.push({ name: 'dashboard' })
  }
}
</script>
