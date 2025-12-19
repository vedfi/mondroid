
var filterTab = document.getElementById("filter-tab");
var sortTab = document.getElementById("sort-tab")
var filterContent = document.getElementById("filter-content");
var sortContent = document.getElementById("sort-content");

// On load: choose tab based on URL parameter `tab` or `t` (values: "atlas" or "local")
(function(){
    var params = new URLSearchParams(window.location.search);
    var tabParam = params.get('tab') || params.get('t');
    if(tabParam === 'filter' || tabParam === 'sort'){
        handleTabContent(tabParam);
    } else {
        handleTabContent('filter');
    }
})();

filterTab.addEventListener("click", ()=>{
    handleTabContent("filter");
});
sortTab.addEventListener("click", ()=>{
    handleTabContent("sort");
});

function handleTabContent(tabName){
    if(tabName === "filter"){
        filterContent.style.setProperty("display", "block")
        sortContent.style.setProperty("display", "none")
        if(!filterTab.classList.contains("is-active")){
            filterTab.classList.add("is-active");
        }
        if(sortTab.classList.contains("is-active")){
            sortTab.classList.remove("is-active");
        }
    }
    else if(tabName === "sort"){
        filterContent.style.setProperty("display", "none")
        sortContent.style.setProperty("display", "block")
        if(!sortTab.classList.contains("is-active")){
            sortTab.classList.add("is-active");
        }
        if(filterTab.classList.contains("is-active")){
            filterTab.classList.remove("is-active");
        }
    }
}