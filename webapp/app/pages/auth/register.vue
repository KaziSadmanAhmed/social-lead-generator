<template lang="pug">
  v-container.fill-height
    v-row(justify="center")
      v-col(cols=12 sm=8 md=6 lg=4)
        v-card
          v-card-title.headline.grey.lighten-2 Register
          v-card-text
            v-container
              v-form(v-model="registerFormValid" ref="registerForm" @submit.prevent="register")
                v-text-field(
                  v-model="fullName"
                  label="Name" type="text"
                  required
                  :loading="loading"
                  :readonly="loading"
                  placeholder="Enter your name"
                  :rules="[validations.required('name')]")
                v-text-field(
                  v-model="email"
                  label="Email"
                  type="email"
                  required
                  :loading="loading"
                  :readonly="loading"
                  placeholder="Enter your email"
                  :rules="[validations.required('email'), validations.emailFormat()]"
                )
                v-text-field(
                  v-model="password"
                  label="Password"
                  type="password"
                  required
                  placeholder="Enter your password"
                  :loading="loading"
                  :readonly="loading"
                  :type="showPassword ? 'text' : 'password'"
                  :append-icon="showPassword ? 'mdi-eye' : 'mdi-eye-off'"
                  :rules="[validations.required('password'), validations.minLength('password', 8), validations.maxLength('password', 20), validations.passwordComplexity()]"
                  @click:append="showPassword = !showPassword"
                )
                v-text-field(
                  v-model="passwordConfirm"
                  label="Confirm Password"
                  type="password"
                  required
                  placeholder="Retype your password"
                  :loading="loading"
                  :readonly="loading"
                  :type="showPassword ? 'text' : 'password'"
                  :append-icon="showPassword ? 'mdi-eye' : 'mdi-eye-off'"
                  :rules="[validations.required('password'), validations.minLength('password', 8), validations.maxLength('password', 20), validations.passwordComplexity(), validations.matchPasswords(password)]"
                  @click:append="showPassword = !showPassword"
                )
                v-flex.mb-4
                  a.body-2(@click="$router.push({name: 'auth-login'})") Already registered? Click here to login
                v-btn(color="primary" type="submit" :loading="loading" :disabled="!registerFormValid") Register
</template>

<script>
import validations from '@/utils/validations'
export default {
  data: () => ({
    fullName: '',
    email: '',
    password: '',
    passwordConfirm: '',
    loading: false,
    showPassword: false,
    registerFormValid: false,
    error: false,
    errorMsg: '',
    validations
  }),
  methods: {
    async register() {
      if (this.$refs.registerForm.validate()) {
        try {
          this.loading = true

          await this.$axios.post('/auth/register', {
            full_name: this.fullName,
            email: this.email,
            password: this.password
          })

          this.$router.push({ name: 'auth-login' })
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
