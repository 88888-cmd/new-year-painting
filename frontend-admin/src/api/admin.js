import request from '@/utils/request'

export function login(data) {
  return request({
    url: '/login',
    method: 'post',
    data
  })
}

export function getInfo() {
  return request({
    url: '/profile',
    method: 'get'
  })
}

export function editPassword(old_password, new_password) {
  return request({
    url: '/editPassword',
    method: 'post',
    data: {
      old_password,
      new_password
    }
  })
}