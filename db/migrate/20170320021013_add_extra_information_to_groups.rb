class AddExtraInformationToGroups < ActiveRecord::Migration
  def change
    create_table :states do |t|
      t.string :name
    end

    add_column :groups, :state_id, :integer, index: true
    add_column :groups, :university, :string
    add_column :groups, :category, :string

    [
      'Aguascalientes',
      'Baja California',
      'Baja California Sur',
      'Campeche',
      'Coahuila',
      'Colima',
      'Chiapas',
      'Chihuahua',
      'Distrito Federal',
      'Durango',
      'Guanajuato',
      'Guerrero',
      'Hidalgo',
      'Jalisco',
      'Estado de México',
      'Michoacán',
      'Morelos',
      'Nayarit',
      'Nuevo León',
      'Oaxaca',
      'Puebla',
      'Querétaro',
      'Quintana Roo',
      'San Luis Potosí',
      'Sinaloa',
      'Sonora',
      'Tabasco',
      'Tamaulipas',
      'Tlaxcala',
      'Veracruz',
      'Yucatán',
      'Zacatecas'
    ].each do |state|
      State.create({name: state})
    end
  end
end
