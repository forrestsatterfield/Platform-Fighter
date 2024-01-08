{
  "resourceType": "GMObject",
  "resourceVersion": "1.0",
  "name": "obj_ui_fade",
  "spriteId": {
    "name": "spr_ui_fade",
    "path": "sprites/spr_ui_fade/spr_ui_fade.yy",
  },
  "solid": false,
  "visible": true,
  "managed": true,
  "spriteMaskId": null,
  "persistent": false,
  "parentObjectId": {
    "name": "obj_ui_parent",
    "path": "objects/obj_ui_parent/obj_ui_parent.yy",
  },
  "physicsObject": false,
  "physicsSensor": false,
  "physicsShape": 1,
  "physicsGroup": 0,
  "physicsDensity": 0.5,
  "physicsRestitution": 0.1,
  "physicsLinearDamping": 0.1,
  "physicsAngularDamping": 0.1,
  "physicsFriction": 0.2,
  "physicsStartAwake": true,
  "physicsKinematic": false,
  "physicsShapePoints": [],
  "eventList": [],
  "properties": [
    {"resourceType":"GMObjectProperty","resourceVersion":"1.0","name":"fade","varType":0,"value":"0","rangeEnabled":false,"rangeMin":0.0,"rangeMax":10.0,"listItems":null,"multiselect":false,"filters":[
        "GMTileSet",
        "GMSprite",
        "GMSound",
        "GMPath",
        "GMScript",
        "GMShader",
        "GMFont",
        "GMTimeLine",
        "GMObject",
        "GMRoom",
      ],},
    {"resourceType":"GMObjectProperty","resourceVersion":"1.0","name":"fade_goal","varType":0,"value":"0","rangeEnabled":false,"rangeMin":0.0,"rangeMax":10.0,"listItems":null,"multiselect":false,"filters":[
        "GMTileSet",
        "GMSprite",
        "GMSound",
        "GMPath",
        "GMScript",
        "GMShader",
        "GMFont",
        "GMTimeLine",
        "GMObject",
        "GMRoom",
      ],},
    {"resourceType":"GMObjectProperty","resourceVersion":"1.0","name":"fade_speed","varType":0,"value":"0.2","rangeEnabled":false,"rangeMin":0.0,"rangeMax":10.0,"listItems":null,"multiselect":false,"filters":[
        "GMTileSet",
        "GMSprite",
        "GMSound",
        "GMPath",
        "GMScript",
        "GMShader",
        "GMFont",
        "GMTimeLine",
        "GMObject",
        "GMRoom",
      ],},
  ],
  "overriddenProperties": [
    {"resourceType":"GMOverriddenProperty","resourceVersion":"1.0","name":"","propertyId":{"name":"ui_script_draw","path":"objects/obj_ui_parent/obj_ui_parent.yy",},"objectId":{"name":"obj_ui_parent","path":"objects/obj_ui_parent/obj_ui_parent.yy",},"value":"ui_fade_draw",},
    {"resourceType":"GMOverriddenProperty","resourceVersion":"1.0","name":"","propertyId":{"name":"ui_script_step","path":"objects/obj_ui_parent/obj_ui_parent.yy",},"objectId":{"name":"obj_ui_parent","path":"objects/obj_ui_parent/obj_ui_parent.yy",},"value":"ui_fade_step",},
  ],
  "parent": {
    "name": "Objects",
    "path": "folders/[Engine]/Menu UI/Objects.yy",
  },
}