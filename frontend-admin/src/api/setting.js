import request from '@/utils/request'

export function getPointsConfig() {
  return request({
    url: '/setting/getPointsConfig',
    method: 'get'
  })
}

export function setPointsConfig(form) {
  return request({
    url: '/setting/setPointsConfig',
    method: 'post',
    data: form
  })
}
