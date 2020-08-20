<template lang="pug">
  v-container.fill-height
    v-row(justify="center")
      v-col(cols=12 sm=8 md=6 lg=4)
        v-card
          v-card-title.headline.grey.lighten-2 Login
          v-card-text
            v-container
              v-form
                v-text-field(v-model="email" label="Email" required)
                v-text-field(v-model="password" label="Password" required)
                v-btn(color="primary" type="submit") Login
</template>

<script>
export default {
  data: () => ({
    email: '',
    password: ''
  })
}
</script>
