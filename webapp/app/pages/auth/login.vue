<template lang="pug">
  v-container.fill-height
    v-row(justify="center")
      v-col(cols=12 sm=8 md=6 lg=4)
        v-alert(type="error" v-model="error" dismissible) {{ errorMsg }}
        v-card
          v-card-title.headline.grey.lighten-2 Login
          v-card-text
            v-container
              v-form(v-model="loginFormValid" ref="loginForm" @submit.prevent="login")
                v-text-field(
                  v-model="auth.email"
                  label="Email"
                  type="email"
                  required
                  :loading="loading"
                  :readonly="loading"
                  placeholder="Enter your email"
                  :rules="[validations.required('email'), validations.emailFormat()]"
                )
                v-text-field(
                  v-model="auth.password"
                  label="Password"
                  type="password"
                  required
                  placeholder="Enter your password"
                  :loading="loading"
                  :readonly="loading"
                  :type="showPassword ? 'text' : 'password'"
                  :append-icon="showPassword ? 'mdi-eye' : 'mdi-eye-off'"
                  :rules="[validations.required('password')]"
                  @click:append="showPassword = !showPassword"
                )
                v-flex.mb-4
                  a.body-2(@click="$router.push({name: 'auth-register'})") Not registered? Click here to register
                v-btn(color="primary" type="submit" :loading="loading" :disabled="!loginFormValid") Login
</template>

<script>
import validations from '@/utils/validations'

export default {
  data: () => ({
    auth: {
      email: '',
      password: ''
    },
    loading: false,
    showPassword: false,
    loginFormValid: false,
    error: false,
    errorMsg: '',
    validations
  }),
  methods: {
    async login() {
      if (this.$refs.loginForm.validate()) {
        try {
          this.loading = true

          const formData = new FormData()

          formData.append('username', this.auth.email)
          formData.append('password', this.auth.password)

          await this.$auth.loginWith('local', {
            data: formData
          })
        } catch (err) {
          this.errorMsg = err.response.data.detail
          this.error = true
        } finally {
          this.loading = false
        }
      }
    }
  }
}
</script>
