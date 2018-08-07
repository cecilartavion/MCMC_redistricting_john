# -*- coding: utf-8 -*-
"""
Created on Thu Apr 19 06:37:55 2018

@author: cecil
"""

from distutils.core import setup,Extension
from Cython.Build import cythonize
import numpy

setup(ext_modules=cythonize(['MCMC_cy.pyx',
							'MCMC_cy_ver3.pyx']), 
	  include_dirs=[numpy.get_include()])