import random
import argparse

if __name__ == '__main__':
	parser = argparse.ArgumentParser(description="generate random number")
	parser.add_argument("-n", "--number", type=int, default=3000, help="Enter a max number to generate random number (default: 3000)")

	args = parser.parse_args()
	num: int = args.number

	rand_num = random.randint(1, num)
	print(f"The random number is: {rand_num}")