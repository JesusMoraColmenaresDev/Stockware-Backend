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
      bounds.width * 0.08, # ID
      bounds.width * 0.15, # Fecha
      bounds.width * 0.35, # Producto
      bounds.width * 0.17, # Cantidad
      bounds.width * 0.12, # Precio Hist.
      bounds.width * 0.13  # Valor Total
    ]
    table(table_data, header: true, width: bounds.width, column_widths: col_widths) do
      # Estilos para la tabla
      row(0).font_style = :bold
      row(0).background_color = "DDDDDD"
      self.row_colors = [ "FFFFFF", "F0F0F0" ]
      self.cell_style = { padding: [ 6, 8, 6, 8 ], border_width: 0.5, border_color: "AAAAAA" }
    end
  end

  def table_data
    # Encabezado de la tabla
    [ [ "ID", "Fecha", "Producto", "Cantidad", "Precio Hist.", "Valor" ] ] +
      # Filas de datos
      @movements.map do |movement|
        [
          movement.id,
          movement.created_at.strftime("%d/%m/%Y"),
          movement.product.name,
          movement.movement,
          format_currency(movement.price),
          format_currency(movement.movement * movement.price)
        ]
      end
  end

  def footer
    # Numera las páginas en la parte inferior
    number_pages "Página <page> de <total>", at: [ bounds.left, 10 ], align: :center, size: 10
  end

  private

  def format_currency(value)
    # Formats the number as currency and ensures it's positive, like in the frontend view.
    "$#{format("%.2f", value.to_f.abs)}"
  end
end
