import os
import sys
import random
import argparse

class RandomCompany:
	def __init__(self, index: int, name: str = ""):
		self.index = index
		self.name = name
		self.page = 0
		self.column = 0
		self.num = 0
		self.toLocation()
	def toLocation(self):
		self.page = self.index // 60 + 1
		rest = rand_num % 60
		self.column = rest // 20 + 1
		self.num = rest % 20
	def ToString(self) -> str:
		return f"{self.index} {self.name} {self.page} {self.column} {self.num}\n"


if __name__ == '__main__':
	parser = argparse.ArgumentParser(description="generate random number")
	parser.add_argument("-n", "--number", type=int, default=3000, help="Enter a max number to generate random number (default: 3000)")

	args = parser.parse_args()
	num: int = args.number

	rand_num = random.randint(1, num)
	company=RandomCompany(index=rand_num)
	print(f"The random number is: {rand_num}")
	print(f"The company at Page: {company.page}, column: {company.column}, order: {company.num}")

	# find and add company name
	try:
		company_name = input("enter company name: ")
	# exit by keyboard or EOF interrupt
	except(KeyboardInterrupt, EOFError):
		sys.exit(1)

	# save company name to file
	file_name="random_company.txt"
	company.name=company_name
	dir_path = os.path.dirname(os.path.abspath(__file__))
	file_path = os.path.join(dir_path, file_name)

	if not os.path.exists(file_path):
		with open(file_path, "w", encoding="utf-8") as f:
			f.write("Index company Page Column Order\n")

	with open(file_path, "a", encoding="utf-8") as f:
		f.write(company.ToString())