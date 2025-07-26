class StockReportPdf < Prawn::Document
  
  def initialize(movements)
    super(page_size: "A4", top_margin: 50)

    @movements = movements
    header
    table_content
    footer
  end

  def header
    text "Reporte de movimientos del stock", size: 24, style: :bold, align: :center
    move_down 30
  end

  def table_content

    col_widths = [
      bounds.width * 0.08, # Columna ID
      bounds.width * 0.35, # Columna Producto
      bounds.width * 0.14, # Columna Cantidad
      bounds.width * 0.15, # Columna Valor (¡Puedes ajustar este porcentaje!)
      bounds.width * 0.28  # Columna Fecha
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
    [["ID", "Producto", "Cantidad", "Valor", "Fecha"]] +
      # Filas de datos
      @movements.map do |movement|
        [
          movement.id,
          movement.product.name,
          movement.movement,
          format("%.2f", movement.movement * movement.product.price),
          movement.created_at.strftime("%Y-%m-%d %H:%M")
        ]
      end
  end

  def footer
    # Numera las páginas en la parte inferior
    number_pages "Página <page> de <total>", at: [bounds.left, 10], align: :center, size: 10
  end

end    