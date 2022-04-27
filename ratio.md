# How to set the whiteboard scale correctly
The whiteboard needs to ensure that everyone in the room sees the same content.

So, before you can determine the whiteboard ratio, you need to determine where your whiteboard will be displayed and what content will be displayed as a way to determine the ratio setting for your whiteboard.

Here are two common examples.

## 1. Content-rich and want to utilize as many screens as possible on various devices

Your product is cross-end and cross-device, maybe a tablet, a cell phone, a landscape phone.

Also the form of content inside is uncertain. There may be videos, PPT, board books...

You want to use as much of the available area of the current screen as possible. Something like this:
<img src="Arts/view-rectangle_magic.png">

To balance the display across all devices, it is recommended that you choose the 16:9 ratio, which is the default setting for Fastboard, and you don't need to set up additional code.

User screens are many times not in 16:9 ratio, so you can keep your `FastRoomView` in 16:9 ratio by adjusting the position of other elements on the view.

One of our open source teaching products, Flat, has similar layout code that achieves high screen utilization by adjusting the position of the video and whiteboard within the screen, see [here](https://github.com/vince-hz/flat-ios/blob/main/Flat/Modules/ClassRoom/ViewController/ClassRoomLayout.swift)

## 2. Fixed style

Your whiteboard style is fixed and you only want to display a specified percentage of the available area.

For example, you now want the users in the room to see a square whiteboard area that everyone is doodling in together.

At this point you should change `Fastboard.globalFastboardRatio` to the 1 : 1.