return {
keyCommands = {
{combos = {{key = 'MOUSE_BTN1'}}, down = iCommandPlaneFire, up = iCommandPlaneFireOff, name = _('Weapon Fire (mouse)'), category = _('Weapons')},
{combos = {{key = 'MOUSE_BTN2'}}, down = iCommandPlaneChangeLock, up = iCommandPlaneChangeLockUp, name = _('Target Lock / Ground Mark (mouse)'), category = _('Sensors')},
{combos = {{key = 'MOUSE_BTN3'}}, down = iCommandPlaneChangeWeapon, name = _('Weapon Change (mouse)'), category = _('Weapons')},
},

axisCommands = {
-- Mouse axes as Joystick / Yoke for Flight Control
{combos = {{key = 'MOUSE_X'}}, action = iCommandPlaneRoll, name = _('Flight Roll (mouse yoke)')},
{combos = {{key = 'MOUSE_Y'}}, action = iCommandPlanePitch, name = _('Flight Pitch (mouse yoke)')},
{combos = {{key = 'MOUSE_Z'}}, action = iCommandPlaneZoomView, name = _('Camera Zoom View (mouse)')},

{action = iCommandPlaneSelecterHorizontal, name = _('TDC Slew Horizontal (mouse)')},
{action = iCommandPlaneSelecterVertical  , name = _('TDC Slew Vertical (mouse)')},
},
}
