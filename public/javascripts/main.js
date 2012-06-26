$(function() {
    'use strict';
//    $("ul.champagne").champagne();

    // Start slideshow button:
    $('#start-slideshow').button().click(function () {
        var options = $(this).data(),
        modal = $(options.target),
        data = modal.data('modal');
        if (data) {
            $.extend(data.options, options);
        } else {
            options = $.extend(modal.data(), options);
        }
        modal.find('.modal-slideshow').find('i')
            .removeClass('icon-play')
            .addClass('icon-pause');
        modal.modal(options);
    });

    // Toggle fullscreen button:
    $('#toggle-fullscreen').button().click(function () {
        var button = $(this),
        root = document.documentElement;
        if (!button.hasClass('active')) {
            $('#modal-gallery').addClass('modal-fullscreen');
            if (root.webkitRequestFullScreen) {
                root.webkitRequestFullScreen(
                    window.Element.ALLOW_KEYBOARD_INPUT
                );
            } else if (root.mozRequestFullScreen) {
                root.mozRequestFullScreen();
            }
        } else {
            $('#modal-gallery').removeClass('modal-fullscreen');
            (document.webkitCancelFullScreen ||
             document.mozCancelFullScreen ||
             $.noop).apply(document);
        }
    });

    $('#modal-gallery').on('load', function () {
        var modalData = $(this).data('modal');
        var img_src = $(modalData.img).attr('src');

        var product_id = null;
        var matches = img_src.match(/http:\/\/images-jp\.amazon\.com\/images\/P\/(.+)\.jpg/);
        if (matches) {
            product_id = matches[1];
            $('a.modal-download').attr('href', "http://www.amazon.co.jp/gp/product/" + product_id);
        }
        // modalData.$links is the list of (filtered) element nodes as jQuery object
        // modalData.img is the img (or canvas) element for the loaded image
        // modalData.options.index is the index of the current link
    });

});
