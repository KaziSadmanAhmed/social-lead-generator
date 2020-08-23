<template lang="pug">
  v-container.fill-height
    v-row(justify="center")
      v-col(cols=12 sm=8 md=6 lg=4)
        v-card
          v-card-title.headline.grey.lighten-2 Register
          v-card-text
            v-container
              v-form
                v-text-field(v-model="fullName" label="Name" type="text" required)
                v-text-field(v-model="email" label="Email" type="email" required)
                v-text-field(v-model="password" label="Password" type="password" required)
                v-text-field(v-model="passwordConfirm" label="Confirm Password" type="password" required)
                v-btn(color="primary" type="submit") Register
</template>

<script>
export default {
  data: () => ({
    email: '',
    password: ''
  })
}
</script>
