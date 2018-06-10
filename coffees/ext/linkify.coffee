walk = (node, callback) ->
  for child in node.childNodes
    callback.call(child)
    walk child, callback

linkify = (text) ->
  # http://stackoverflow.com/questions/37684/how-to-replace-plain-urls-with-links
  urlPattern = (
    /\b(?:https?|ftp):\/\/[a-z0-9-+&@#\/%?=~_|!:,.;]*[a-z0-9-+&@#\/%=~_|]/gim)
  pseudoUrlPattern = /(^|[^\/])(www\.[\S]+(\b|$))/gim
  emailAddressPattern = /[\w.]+@[a-zA-Z_-]+?(?:\.[a-zA-Z]{2,6})+/gim
  arr = [text]
  arr = linkifyByRegex arr, "url", urlPattern
  arr = linkifyByRegex arr, "pseudoUrl", pseudoUrlPattern
  arr = linkifyByRegex arr, "email", emailAddressPattern
  ret = ""
  for elm in arr
    if not elm.linkType?
      ret += elm
    else
      m = elm.match
      switch elm.linkType
        when "url"
          ret += (
            "<a href=\"#{m[0]}\" target=\"_blank\">#{m[0]}</a>")
        when "pseudoUrl"
          ret += (
            "#{m[1]}<a href=\"http://#{m[2]}\" target=\"_blank\">#{m[2]}</a>")
        when "email"
          ret += "<a href=\"mailto:#{m[0]}\" target=\"_blank\">#{m[0]}</a>"
        else
          console.log "This cannot be possible"
  return ret

linkifyByRegex = (arr, linkType, regex) ->
  ret = []
  for str in arr
    if str.linkType?
      ret.push str
    else
      lastIndex = 0
      while ((m = regex.exec(str)) isnt null)
        ret.push str[lastIndex...m.index]
        ret.push
          linkType: linkType,
          match: m
        lastIndex = m.index + m[0].length
      if lastIndex < str.length
        ret.push str[lastIndex...str.length]
  return ret

tags =
  '&': '&amp;'
  '<': '&lt;'
  '>': '&gt;'

escape = (s) -> s.replace(/[&<>]/g, (tag) -> tags[tag] or tag)

window.linkifyLine = (line) ->
  walk line, ->
    if @nodeType is 3
      val = @nodeValue
      linkified = linkify escape(val)
      if linkified isnt val
        newNode = document.createElement('span')
        newNode.innerHTML = linkified
        @parentElement.replaceChild newNode, @
        true
