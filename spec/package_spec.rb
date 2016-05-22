module STARMAN
  RSpec.describe 'Hdf5' do
    it 'has correct languages.' do
      PackageLoader.load_package :hdf5
      hdf5 = PackageLoader.packages[:hdf5][:instance]
      expect(hdf5.languages).to eq [:c, :cxx, :fortran]
      expect(hdf5.options[:'with-cxx'].value).to eq true
      hdf5.options[:'with-cxx'].check 'false'
      expect(hdf5.options[:'with-cxx'].value).to eq false
      PackageLoader.load_package :hdf5, :force
      expect(hdf5.languages).to eq [:c, :fortran]
    end
  end

  RSpec.describe 'Netcdf' do
    it 'has correct dependencies.' do
      PackageLoader.load_package :netcdf_c
      netcdf_c = PackageLoader.packages[:netcdf_c][:instance]
      expect(netcdf_c.dependencies.keys).to eq [:hdf5]
      expect(netcdf_c.options[:'use-mpi'].value).to eq false
      netcdf_c.options[:'use-mpi'].check 'true'
      expect(netcdf_c.options[:'use-mpi'].value).to eq true
      PackageLoader.load_package :netcdf_c, :force
      expect(netcdf_c.dependencies.keys).to eq [:hdf5, :pnetcdf]
    end
  end
end
