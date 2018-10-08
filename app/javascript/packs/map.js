import GMaps from 'gmaps/gmaps.js';

const mapElement = document.getElementById('map');
if (mapElement) { // don't try to build a map if there's no div#map to inject in
    const map = new GMaps({ el: '#map', lat: 39.8283, lng: -98.579});
    map.setZoom(4);

   var statesLayer = new google.maps.KmlLayer({
     url: mapElement.dataset.states,
     suppressInfoWindows: true,
     preserveViewport: false,
     map: map.map
   });
  
   var countiesLayer = new google.maps.KmlLayer({
     url: mapElement.dataset.counties,
     suppressInfoWindows: true,
     preserveViewport: false,
     map: map.map
   });
}
