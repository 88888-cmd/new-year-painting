import request from '@/utils/request'

export function getList() {
  return request({
    url: '/banner/getList',
    method: 'get'
  })
}

export function add(data) {
  return request({
    url: '/banner/add',
    method: 'post',
    data
  })
}

export function del(id) {
  return request({
    url: '/banner/delete',
    method: 'post',
    data: {
      banner_id: id
    }
  })
}

export function getArticleContent(id) {
  return request({
    url: '/banner/getArticleContent',
    method: 'get',
    params: {
      banner_id: id
    }
  })
}

export function setArticleContent(id, article_content) {
  return request({
    url: '/banner/setArticleContent',
    method: 'post',
    data: {
      banner_id: id,
      article_content: article_content
    }
  })
}
