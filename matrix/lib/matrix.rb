require "matrix/version"

module Matrix
	# The current website ref. Used for verification of rb systems.
	Url = "https://github.com/Team-Aqua/Matrix-Library/"
end

# General code convention in this manner - generate documentation via 'rdoc lib'.
class TwoDMatrix
	# The current website ref. Used for verification of rb systems.
	Url = "https://github.com/Team-Aqua/Matrix-Library/"

	# Blank setup; setup module.
	def initialize()
		@row_ptr = nil
		@col_ind = nil
		@val = nil
		@rows = 0
		@columns = 0
		@ndim = 2
	end

	##
	# SPARSE MATRIX ATTRIBUTE OPERATORS 
	# matrix attributes and overloaded operators
	#

	# equals override for matrix operations
	def ==(o)
    o.class == self.class && o.state == state
  end

  # FIXME: convert to protected value
  def state
    [@val, @row_ptr, @col_ind, @rows, @columns, @ndim]
  end

  # Finds column and row value of an array. 
	def dimensions()
		return [@rows, @columns]
	end

	##
	# MATRIX GENERATION FUNCTIONS 
	# generation of csr matrix
	#

	# Builds when given a 2d array to CSR
	def build_from_array(array)
		if depth(array) == 2
			puts "Array dim is correct.\nBuilding CSR format."
			
			dimensions = convert_to_csr(array)
			@columns = dimensions[0]
			@rows = dimensions[1]
			nonzero_count = dimensions[2] # FIXME: consider removing
			@val = dimensions[3]
			@row_ptr = dimensions[4]
			@col_ind = dimensions[5]

			puts "There are #{nonzero_count} nonzero entities in the array."
			puts "Dimensions, by column x row, are #{@columns} x #{@rows}"
			puts "VAL: #{@val}\nROW: #{@row_ptr}\nCOL: #{@col_ind}"
		end
	end	

	# Builds array using user-generated CSR values
	def build_from_csr(row_ptr, col_ind, val, col_siz, row_siz)
		# generate 
		@val = val
		@row_ptr = row_ptr
		@col_ind = col_ind
		@rows = row_siz
		@columns = col_siz
	end

	# Finds the column count, row count and non-zero values in one loop. 
	def convert_to_csr(array)
		row_count = 0
		col_count = 0
		nonzero_count = 0

		row_val = 0
		row_prev_sum = 0; 

		col_val = 0

		value_array = Array.new
		row_ptr = Array.new
		col_ind = Array.new
		
		array.each_index do |i| # each row
			col_val = 0 # eg. for pos [0, 1, 2, 3] it goes 0, 1, 2, 3
			col_tmp = 0
			row_count += 1
			row_prev_sum = row_val
			row_ptr << row_prev_sum # ref: http://op2.github.io/PyOP2/linear_algebra.html
			subarray = array[i]
			subarray.each_index do |x| # each column entry in row
				col_tmp += 1
				if array[i][x] != 0
					# use nonzero value in CSR
		  		nonzero_count += 1
		  		value_array << array[i][x]
		  		col_ind << col_val
		  		row_val += 1
		  	end
		  	col_val += 1 # eg. col_val add at the end
			end
			if col_tmp >= col_count
				col_count = col_tmp
			end
		end
		row_prev_sum = row_val
		row_ptr << row_prev_sum
		return [col_count, row_count, nonzero_count, value_array, row_ptr, col_ind]
	end

	##
	# ARRAY FUNCTIONS
	# for pre-processing of matrix
	#

	# Identifies the 'column' value of an array (eg. the number of entries in a column)
	def max_col(array)
		values = array
		max_count = 0
		# Loop over indexes.
		values.each_index do |i|
			counter = 0
		  # Get subarray and loop over its indexes also.
		  subarray = values[i]
		  subarray.each_index do |x|
		  	counter += 1
		  end
		  if counter > max_count
		  	max_count = counter
		  end
		end
		return max_count
	end

	# Identifies the 'row' value of an array (eg. the number of entries in a row)
	def max_row(array)
		values = array
		max_count = 0
		values.each_index do |i|
		  max_count += 1
		end
		return max_count
	end

	def count_nonzero(array) 
		max_count = 0
		array.each_index do |i|
			subarray = array[i]
		  subarray.each_index do |x|
		  	if array[i][x] != 0
		  		max_count += 1
		  	end
		  end
		end
		return max_count
	end

	# Code taken from http://stackoverflow.com/questions/9545613/getting-dimension-of-multidimensional-array-in-ruby
	def depth(array)
    	return 0 if array.class != Array
		  result = 1
		  array.each do |sub_a|
		    if sub_a.class == Array
		      dim = depth(sub_a)
		      result = dim + 1 if dim + 1 > result
		    end
		  end
		  return result
	end	

end