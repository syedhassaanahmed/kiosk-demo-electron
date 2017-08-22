window.$ = window.jQuery = require('jquery')
require('jquery-ui-dist/jquery-ui.js')

const videos = [
    "https://v.ftcdn.net/00/93/30/28/700_F_93302848_Hlps2MDByZ1se1MJG80lFKT341hjjGnq_ST.mp4",
    "https://v.ftcdn.net/01/33/62/00/700_F_133620029_EGRx2ttoOrpxJOq8EGCzBCB1Xy96hCVm_ST.mp4",
    "https://v.ftcdn.net/00/38/85/55/240_F_38855533_E6749qdKyfaRZKkg2NQYgvaitOyguYHy_ST.mp4",
    "https://v.ftcdn.net/01/07/96/73/240_F_107967334_HEvbPCF2xKTOjXP4CxpeZLEZBz1dSWzZ_ST.mp4",
    "https://v.ftcdn.net/00/73/23/45/240_F_73234590_x0bGf4HfNJKT35sjXfDHSVnBY24mG4W3_ST.mp4",
    "https://v.ftcdn.net/00/84/82/38/240_F_84823828_YQ1542nNZkmweBequVWg0eqDLKicYUTw_ST.mp4"
]

$(function () {
    for(let i = 0; i < videos.length; i++){
        var video = $('<video />', {
            src: videos[i],
            autoplay: true,
            loop: true,
            class: 'video'
        });
        video.appendTo($('#videosContainer'));
    }

    $("#videosContainer").sortable()
    $("#videosContainer").disableSelection()
})