/* eslint-disable */
  ;(function (global) {
  'use strict'

  var $ = global.jQuery
  var GOVUK = global.GOVUK || {}

  var prefixes = ['webkit', 'Moz', 'ms', 'O'] // Vendor prefixes
  var animations = { } // Animation rules keyed by their name
  var useCssAnimations // Whether to use CSS animations or setTimeout
  var sheet // A stylesheet to hold the @keyframe or VML rules.

  var defaults = {
    container: 'loader',   // The name of the loader container
    label: false,          // The label of the loader
    labelText: 'Loading, please wait.', // The text for the label
    size: 100,             // The size of the loader
    lines: 12,             // The number of lines to draw
    length: 7,             // The length of each line
    width: 5,              // The line thickness
    radius: 10,            // The radius of the inner circle
    corners: 0.5,          // Roundness (0..1)
    color: '#000',         // #rgb or #rrggbb
    opacity: 0.25,         // Opacity of the lines
    rotate: 0,             // Rotation offset
    direction: 1,          // 1: clockwise, -1: counterclockwise
    speed: 1,              // Rounds per second
    trail: 100,            // Afterglow percentage
    fps: 20                // Frames per second when using setTimeout()
  }

  function Loader () {
    var self = this
    var container
    var element
    var options
    var label
  }

  Loader.prototype.setContainer = function (container) {
    this.container = container
  }

  // Utility function to create HTML elements. Optionally properties can be passed.
  Loader.prototype.createSvgElement = function (tag, prop) {
    var element
    var n
    element = document.createElementNS('http://www.w3.org/2000/svg', tag)
    for (n in prop) element.setAttribute(n, prop[n])
    return element
  }

  // Utility function to create SVG elements. Optionally properties can be passed.
  Loader.prototype.createHtmlElement = function (tag, prop) {
    var element, n
    element = document.createElement(tag || 'div')
    for (n in prop) element.setAttribute(n, prop[n])
    return element
  }

  // Appends children to element
  Loader.prototype.insertElement = function (parent /* child1, child2, ... */) {
    for (var i = 1, n = arguments.length; i < n; i++) {
      parent.appendChild(arguments[i])
    }
    return parent
  }

  // Creates an opacity keyframe animation rule and returns its name.
  // Since most mobile Webkits have timing issues with animation-delay, we create separate rules for each line/segment.
  Loader.prototype.addAnimation = function (alpha, trail, i, lines) {
    var name = ['opacity', trail, ~~(alpha * 100), i, lines].join('-')
    var start = 0.01 + i / lines * 100
    var z = Math.max(1 - (1 - alpha) / trail * (100 - start), alpha)
    var prefix = useCssAnimations.substring(0, useCssAnimations.indexOf('Animation')).toLowerCase()
    var pre = prefix && '-' + prefix + '-' || ''

    if (!animations[name]) {
      sheet.insertRule(
        '@' + pre + 'keyframes ' + name + '{' +
        '0%{opacity:' + z + '}' +
        start + '%{opacity:' + alpha + '}' +
        (start + 0.02) + '%{opacity:1}' +
        (start + trail) % 100 + '%{opacity:' + alpha + '}' +
        '100%{opacity:' + z + '}' +
        '}', sheet.cssRules.length)
      animations[name] = 1
    }
    return name
  }

  // Tries various vendor prefixes and returns the first supported property.
  Loader.prototype.vendor = function (el, prop) {
    var s = el.style
    var pp
    var i

    prop = prop.charAt(0).toUpperCase() + prop.slice(1)
    if (s[prop] !== undefined) return prop
    for (i = 0; i < prefixes.length; i++) {
      pp = prefixes[i] + prop
      if (s[pp] !== undefined) return pp
    }
  }

  // Sets multiple style properties at once.
  Loader.prototype.css = function (el, prop) {
    for (var n in prop) {
      el.style[Loader.prototype.vendor(el, n) || n] = prop[n]
    }

    return el
  }

  // Fills in default values.
  Loader.prototype.merge = function (obj) {
    for (var i = 1; i < arguments.length; i++) {
      var def = arguments[i]
      for (var n in def) {
        if (obj[n] === undefined) obj[n] = def[n]
      }
    }
    return obj
  }

  // Returns the line color from the given string or array.
  Loader.prototype.getColor = function (color, idx) {
    return typeof color === 'string' ? color : color[idx % color.length]
  }

  Loader.prototype.attach = function (options) {
    // this.stop()
    // Reference the loading container
    var container = document.getElementById(options.container)

    if (container) {
      // Create the loading element
      var element = Loader.prototype.createHtmlElement('div', {
        'id': 'loader',
        'class': 'govuk-c-loader',
        'role': 'alert', // role progressbar, slider, status
        'aria-busy': 'true',
        'aria-atomic': true,
        'aria-label': options.labelText,
        'aria-labelledby': 'loading-label', // for generic or updating messages
        'aria-describedby': 'loading-label',
        'aria-live': 'polite',
        // 'aria-valuetext': options.labelText, //human readable text alternative of aria-valuenow
        // 'aria-valuemin': '0',
        // 'aria-valuenow': '0',
        // 'aria-valuemax': '100',
        'tabindex': '0'
      })

      // Create the spinner
      var spinner
      if (!options.useVml) {
        // SVG version
        spinner = Loader.prototype.createSvgElement('svg', {
          'version': '1.1',
          'xmlns': 'http://www.w3.org/2000/svg',
          'class': 'govuk-c-loader__spinner',
          'width': options.size,
          'height': options.size,
          'viewBox': '-32 -32 64 64',
          'preserveAspectRatio': 'xMidYMid meet'
        })
      } else {
        // VML version
        spinner = Loader.prototype.createHtmlElement('div', {
          'class': 'govuk-c-loader__spinner',
          'style': 'left: 50%; width: ' + options.size + 'px; height: ' + options.size + 'px; position: absolute; top: 50%;'
          // 'style': 'position: relative; left: 50%; top: 50px; height: 100px; width: 100px;'
        })
      }
      element.appendChild(spinner)

      // Create the label
      if (options.label) {
        var label = Loader.prototype.createHtmlElement('label', {
          'id': 'loading-label',
          'class': 'govuk-c-loader__label',
          'role': 'status',
          'aria-live': 'polite',
          'aria-atomic': false
        })
        label.innerHTML = options.labelText
        element.appendChild(label)
        // Save label reference for updates
        this.label = label
      }

      // Set ARIA attributes to show progress
      if (options.progress) {
        element.setAttribute('role', 'slider')
        element.setAttribute('aria-valuemin', '0')
        element.setAttribute('aria-valuenow', '0')
        element.setAttribute('aria-valuemax', '100')
      }

      // Insert the loading elements
      container.insertBefore(element, container.firstChild || null)

      // Save references
      this.container = container
      this.element = element
      this.options = options

      // Add lines to the spinner element
      Loader.prototype.lines(spinner, options)

      // If no CSS animation support, use setTimeout() instead
      if (!useCssAnimations) {
        Loader.prototype.useJsAnimations(spinner, options)
      }
    }
    return this
  }

  Loader.prototype.useJsAnimations = function (element, options) {
    var i = 0
    var start = (options.lines - 1) * (1 - options.direction) / 2
    var alpha
    var fps = options.fps
    var f = fps / options.speed
    var ostep = (1 - options.opacity) / (f * options.trail / 100)
    var astep = f / options.lines

    ;(function animate () {
      i++
      for (var j = 0; j < options.lines; j++) {
        alpha = Math.max(1 - (i + (options.lines - j) * astep) % f * ostep, options.opacity)
        Loader.prototype.opacity(element, j * options.direction + start, alpha)
      }
      this.timeout = element && setTimeout(animate, ~~(1000 / fps))
    })()
  }

  Loader.prototype.lines = function (element, options) {
    var i = 0
    var start = (options.lines - 1) * (1 - options.direction) / 2
    var line

    for (; i < options.lines; i++) {
      line = Loader.prototype.css(Loader.prototype.createSvgElement('rect', {
        fill: options.color,
        width: options.length + options.width,
        height: options.width,
        rx: (options.corners * options.width),
        ry: (options.corners * options.width),
        transform: 'rotate(' + ~~(360 / options.lines * i + options.rotate) + ', 0, 2) translate(' + options.radius + ' 0)',
        opacity: options.opacity
      }), {
        animation: useCssAnimations && Loader.prototype.addAnimation(options.opacity, options.trail, start + i * options.direction, options.lines) + ' ' + 1 / options.speed + 's linear infinite'
      })

      Loader.prototype.insertElement(element, line)
    }
    return element
  }

  // Internal method that adjusts the opacity of a single line.
  // Will be overwritten in VML fallback mode below.
  Loader.prototype.opacity = function (element, i, value) {
    if (i < element.childNodes.length) {
      element.childNodes[i].setAttribute('opacity', value)
    }
  }

  // Returns path data for a rectangle with rounded right corners.
  // The top-left corner is ⟨x,y⟩.
  // Loader.prototype.rightRoundedRect = function (x, y, width, height, radius) {
  //   return 'M' + x + ',' + y +
  //   'h' + (width - radius) +
  //   'a' + radius + ',' + radius + ' 0 0 1 ' + radius + ',' + radius +
  //   'v' + (height - 2 * radius) +
  //   'a' + radius + ',' + radius + ' 0 0 1 ' + -radius + ',' + radius +
  //   'h' + (radius - width) +
  //   'z'
  // }
  // rects.enter().append("path").attr("d", rightRoundedRect())

  Loader.prototype.initVML = function (options) {
    // Utility function to create VML elements. Optionally properties can be passed.
    Loader.prototype.createVmlElement = function (tag, attr) {
      return Loader.prototype.createHtmlElement('<' + tag + ' xmlns="urn:schemas-microsoft.com:vml" class="loading-vml">', attr)
    }

    // No CSS transforms but VML support, add a CSS rule for VML elements:
    sheet.addRule('.loading-vml', 'behavior:url(#default#VML)')

    Loader.prototype.lines = function (element, options) {
      var r = options.length + options.width
      var s = 2 * r

      function createGroupElement () {
        return Loader.prototype.css(Loader.prototype.createVmlElement('group', {coordsize: s + ' ' + s, coordorigin: -r + ' ' + -r}), {width: s, height: s})
      }

      var margin = -(options.width + options.length) * 2 + 'px'
      var g = Loader.prototype.css(createGroupElement(), {position: 'absolute', top: margin, left: margin})
      var i

      function seg (i, dx) {
        Loader.prototype.insertElement(g,
          Loader.prototype.insertElement(Loader.prototype.css(
            createGroupElement(), {
              rotation: 360 / options.lines * i + 'deg',
              left: ~~dx
            }
          ),
          Loader.prototype.insertElement(Loader.prototype.css(
              Loader.prototype.createVmlElement('roundrect', {arcsize: options.corners}), {
                width: r,
                height: options.width,
                left: options.radius,
                top: -options.width >> 1
              }
            ),
            // Loader.prototype.createVmlElement('fill', {color: getColor(options.color, i), opacity: options.opacity}),
            Loader.prototype.createVmlElement('fill', {color: options.color, opacity: options.opacity}),
            Loader.prototype.createVmlElement('stroke', {opacity: 0}) // transparent stroke to fix color bleeding upon opacity change
            )
          )
        )
      }

      for (i = 1; i <= options.lines; i++) {
        seg(i, -2)
      }
      return Loader.prototype.insertElement(element, g)
    }

    Loader.prototype.opacity = function (element, i, value) {
      var c = element.firstChild
      if (c && i < c.childNodes.length) {
        c = c.childNodes[i]; c = c && c.firstChild; c = c && c.firstChild
        if (c) c.opacity = value
      }
    }
  }

  Loader.prototype.init = function (options) {
    if (options && options.container) {
      options = Loader.prototype.merge(options || {}, Loader.defaults, defaults)

      // Initialise style injection
      sheet = (function () {
        var element = Loader.prototype.createHtmlElement('style', {type: 'text/css'})
        Loader.prototype.insertElement(document.getElementsByTagName('head')[0], element)
        return element.sheet || element.styleSheet
      }())

      // Probe html group element for VML
      var probe = Loader.prototype.css(Loader.prototype.createHtmlElement('group'), {behavior: 'url(#default#VML)'})

      // Test probe element for transform support
      if (!Loader.prototype.vendor(probe, 'transform') && probe.adj) {
        Loader.prototype.initVML()
        options.useVml = true
      } else {
        useCssAnimations = Loader.prototype.vendor(probe, 'animation')
      }
      Loader.prototype.attach(options)
    } else {
      window.console.warn('Please specify a container for the loader')
    }
    return this
  }

  Loader.prototype.updateMessage = function (message) {
    this.label.innerHTML = message
  }

  Loader.prototype.updateProgress = function (progress) {
    this.element.setAttribute('aria-valuenow', progress)
  }

  Loader.prototype.updateContainer = function (content) {
    this.container.innerHTML = content
  }

  // Stops and removes the Loading
  Loader.prototype.stop = function (element) {
    if (!element) element = document.getElementById('loader')
    if (element) {
      clearTimeout(this.timeout)
      if (element.parentNode) element.parentNode.removeChild(element)
      element = undefined
    }
    return this
  }

  GOVUK.Loader = Loader
  global.GOVUK = GOVUK
})(window); // eslint-disable-line semi
