var _szubtsovskiy$elm_infinite_scroll$Native_Scroll = function() {
  var rAF = typeof requestAnimationFrame !== 'undefined'
    ? requestAnimationFrame
    : function(callback) { callback(); };

  function withNode(id, doStuff) {
    return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
      rAF(function() {
        var element = document.getElementById(id);
        if (element === null) {
          callback(_elm_lang$core$Native_Scheduler.fail({ctor: 'NotFound', _0: id}));
          return;
        }

        callback(_elm_lang$core$Native_Scheduler.succeed(doStuff(element)));
      })
    });
  }

  function toY(id, height) {
    return withNode(id, function(element) {
      element.scrollTop = height;
      return _elm_lang$core$Native_Utils.Tuple0;
    });
  }

  return {
    toY: F2(toY)
  }
}();