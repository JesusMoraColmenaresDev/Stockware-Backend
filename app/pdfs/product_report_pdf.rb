class ProductReportPdf < Prawn::Document
  
  def initialize(products)
    super(page_size: "A4", top_margin: 50)

    @products = products
    header
    table_content
    footer
  end

  def header
    text "Reporte de productos en el stock", size: 24, style: :bold, align: :center
    move_down 30
  end

  def table_content

    col_widths = [
      bounds.width * 0.08, # Columna ID
      bounds.width * 0.45, # Columna nombre del Producto
      bounds.width * 0.12, # Columna Precio
      bounds.width * 0.20, # Columna Categoria
      bounds.width * 0.15  # Columna Cantidad en Stock
    ]
    table(table_data, header: true, width: bounds.width, column_widths: col_widths) do

      # Estilos para la tabla
      row(0).font_style = :bold
      row(0).background_color = 'DDDDDD'
      self.row_colors = ["FFFFFF", "F0F0F0"]
      self.cell_style = { padding: [6, 8, 6, 8], border_width: 0.5, border_color: "AAAAAA" }
    end
  end

  def table_data
    # Encabezado de la tabla
    [["ID", "Nombre", "Precio", "Categoría", "Stock"]] +
      # Filas de datos
      @products.map do |product|
        [
          product.id,
          product.name,
          format("%.2f", product.price),
          product.category.name,
          product.stock
        ]
      end
  end

  def footer
    # Numera las páginas en la parte inferior
    number_pages "Página <page> de <total>", at: [bounds.left, 10], align: :center, size: 10
  end

end  