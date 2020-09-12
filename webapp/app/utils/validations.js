const required = (propertyType) => {
  return (v) => (v && v.length > 0) || `You must enter a ${propertyType}`
}

const minLength = (propertyType, minLength) => {
  return (v) =>
    (v && v.length >= minLength) ||
    `${propertyType} must be at least ${minLength} characters`
}

const maxLength = (propertyType, maxLength) => {
  return (v) =>
    (v && v.length <= maxLength) ||
    `${propertyType} must be less than ${maxLength} characters`
}

const passwordComplexity = (propertyType) => {
  const regExp = /(?:[A-Za-z].*?\d|\d.*?[A-Za-z])/
  return (value) =>
    (value && regExp.test(value)) ||
    `${propertyType} must have at least one letter and one number`
}

const emailFormat = () => {
  const regex = /^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,24})+$/
  return (v) => (v && regex.test(v)) || 'Must be a valid email'
}

export default {
  required,
  minLength,
  maxLength,
  passwordComplexity,
  emailFormat
}
