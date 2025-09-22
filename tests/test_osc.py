#!/usr/bin/python3
import argparse
from random import random
from sys import argv
from pythonosc import udp_client
from time import sleep

parser = argparse.ArgumentParser()
parser.add_argument("-a", "--osc-address", default="127.0.0.1",
    help="Ip of the device to send the osc to.")
parser.add_argument("-o", "--osc-out-port", type=int, default=4646,
    help="Port of the remote osc device")
arguments = parser.parse_args()

osc_client = udp_client.SimpleUDPClient(arguments.osc_address, arguments.osc_out_port, allow_broadcast=True)

def send_all_the_osc():
    osc_client.send_message(f"/control/show_source_numbers", True)
    osc_client.send_message(f"/control/show_speaker_numbers", True)
    osc_client.send_message(f"/control/spat_mode", "cube")
    osc_client.send_message(f"/control/show_hall", True)
    osc_client.send_message(f"/control/show_sphere_or_cube", True)

    for i in range(50):
        val = i*1.2/50
        # source osc messages
        osc_client.send_message(f"/source/{i}/color", [val/(i%3 + 1), val/(i%5 + 1), val/(i%7 + 1)])
        osc_client.send_message(f"/source/{i}/position", [val * (i%2 - 1), val * ((i+1)%2 - 1), val])
        osc_client.send_message(f"/source/{i}/transparency", val+0.2)
        osc_client.send_message(f"/source/{i}/azimuth_span", val/10)
        osc_client.send_message(f"/source/{i}/elevation_span", val/10)
        # speaker osc messages
        osc_client.send_message(f"/speaker/{i}/alpha", val)
        osc_client.send_message(f"/speaker/{i}/center_position", [-1 + (2*i%5),-1,-1])
        osc_client.send_message(f"/speaker/{i}/position", [val * (i%2 - 1) + 0.1, val * ((i+1)%2 - 1) + 0.1, val + 0.1])
        if i == 40:
            osc_client.send_message(f"/speaker/{i}/is_selected", True)
        if i%10 == 0:
            osc_client.send_message(f"/speaker/{i}/is_direct_out_only", True)
        # Godot's PeerUDP thingy has a fixed size circular buffer. If python sends osc as fast as it can,
        # messages are lost before being processed.
        sleep(0.005)

print("sending osc")
send_all_the_osc()
print("done")
