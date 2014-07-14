/**
 * Created by nicopaez on 7/9/14.
 */

function change(sender) {
    var currentValue = document.getElementById("project_default_watchers").value;
    var newValue = "";
    if (sender.checked) {
        newValue = sender.value + "," + currentValue;
    }
    else {
        newValue = currentValue.replace(sender.value + ",", "");
    }
    document.getElementById("project_default_watchers").value = newValue;
}