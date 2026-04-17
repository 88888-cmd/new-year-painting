import request from '@/utils/request'

export function getList() {
  return request({
    url: '/paintingCalendar/getList',
    method: 'get'
  })
}

export function add(data) {
  return request({
    url: '/paintingCalendar/add',
    method: 'post',
    data
  })
}

export function del(id) {
  return request({
    url: '/paintingCalendar/delete',
    method: 'post',
    data: {
      painting_calendar_id: id
    }
  })
}
