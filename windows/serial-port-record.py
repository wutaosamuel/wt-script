import os
import sys
import time
import argparse
import threading
from serial import Serial
from serial.tools import list_ports

class SerialWithTime:
	def __init__(self, time: float = 0.0, data: bytes = bytes()):
		self.time = time
		self.data = data

class SerialWithTimeList:
	def __init__(self):
		self.list = []
	def append(self, time: float, data: bytes):
		self.list.append(SerialWithTime(time, data))
	def append_serial(self, data: SerialWithTime):
		self.list.append(data)
	def print(self): # TODO: auto save & print with time or the number of object
		for item in self.list:
			print(time.strftime("%Y-%m-%d %H:%M:%S:", time.localtime(item.time)), item.data)
	def save(self, filename: str = "autosave.txt") -> str: # TODO: auto save  with time or the number of object
		# if no .txt suffix, automatically add
		filename = filename.strip()
		if not filename.lower().endswith('.txt'):
			filename += ".txt"

		base, ext = os.path.splitext(filename)
		counter = 1
		new_filename = filename

		# check if there is a file with the same name
		# if yes, add numbered suffix
		while os.path.exists(new_filename):
			new_filename = f"{base}{counter}{ext}"
			counter += 1

		# create
		with open(new_filename, 'w', encoding='utf-8') as f:
			for item in self.list:
				f.write(time.strftime("%Y-%m-%d %H:%M:%S ", time.localtime(item.time)))
				f.write(" ")
				f.write(f"{item.time}")
				f.write(" ")
				f.write(f"{list(item.data)}")
				f.write("\n")

		return new_filename

def list_port():
	ports = list_ports.comports()
	if not ports:
		print('No serial ports found')
	else:
		for port in ports:
			print(port)

def com_print(port: str = '', baudrate: int = 115200, is_save: bool = False, filename: str = "autosave.txt"):
	timed_list = SerialWithTimeList()

	if port == '':
		print("Please select a serial port")
		return
	
	com = Serial(port=port, baudrate=baudrate)
	def _read_com():
		while True:
			if com.in_waiting > 0:
				content = com.read(com.in_waiting)
				now = time.time()
				timed_list.append(now, content)
				print(time.strftime("%Y-%m-%d %H:%M:%S:", time.localtime(now)), content)
			else:
				time.sleep(0.1)

	# Read data
	try:
		print("Start to read data, press Ctrl+C to exist")
		_read_com()
	except KeyboardInterrupt:
		print("Exit")
	finally:
		com.close()
		# TODO: auto save with time or the number of object
		if is_save:
			print()
			print("Save data to {filename}".format(filename=filename))
			timed_list.save(filename=filename)

def get_time():
	now = time.time()
	print(now)
	print(time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(now)))

def main():
	parser = argparse.ArgumentParser(description="com port record")
	parser.add_argument('-l', '--list', action='store_true', help='Print serial ports')
	parser.add_argument('-p', '--port', type=str, help='Specify the COMx port (str)')
	parser.add_argument('-b', '--baudrate', type=int, help='Specify the baud rate (int)')
	parser.add_argument('-i', '--input', type=str, nargs='?', const=True, help='File name and path to save (optional)')

	args = parser.parse_args()
	port: str = ""
	baud_rate: int = 115200
	input_file: str = "autosave.txt"
	is_save: bool = True

	if args.list:
		list_port()
		sys.exit(0)

	if args.port is None:
		print("Error: COM port is required, please specify it with -p | --port.")
		sys.exit(1)
	port = args.port

	if args.baudrate is not None:
		baud_rate = args.baudrate

	if args.input is None:
		is_save = False
	elif args.input is True:
		pass
	else:
		input_file = args.input

	if not isinstance(port, str):
		print("Error: -p | --port must be a string value.")
		sys.exit(1)

	if not isinstance(baud_rate, int):
		print("Error: -b | --baudrate must be an integer value.")
		sys.exit(1)

	if not isinstance(input_file, str):
		print("Error: -i | --input file name must be a string value.")
		sys.exit(1)

	print(f"Port: {port}")
	print(f"Baudrate: {baud_rate}")
	print(f"Save: {is_save}")
	print(f"File to save: {input_file}")
	print()

	com_print(port=port, baudrate=baud_rate, is_save=is_save, filename=input_file)

if __name__ == '__main__':
	main()
