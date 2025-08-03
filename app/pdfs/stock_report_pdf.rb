require_relative 'base_report_pdf'

class StockReportPdf < BaseReportPdf
  def initialize(movements, user, start_date: nil, end_date: nil)
    super(user) # Pasa el usuario a la clase padre (BaseReportPdf)
    @movements = movements
    @start_date = start_date
    @end_date = end_date
  end

  # Sobrescribimos el método `render` para usar el `render_report` del padre
  def render
    # 1. Build the document content with an English title.
    render_report(
      title: "Stock Movement Report",
      start_date: @start_date,
      end_date: @end_date
    ) { table_content }
    # 2. Llama al `render` original de Prawn para generar el PDF.
    super
  end

  private

  def table_content
    col_widths = [
      bounds.width * 0.08, # ID
      bounds.width * 0.18, # Date
      bounds.width * 0.22, # Product
      bounds.width * 0.15, # User
      bounds.width * 0.12, # Quantity
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
    # Table header in English
    [ [ "ID", "Date", "Product", "User", "Quantity", "Hist. Price", "Value" ] ] +
      # Filas de datos
      @movements.map do |movement|
        [
          movement.id,
          movement.created_at.strftime("%d/%m/%Y"),
          movement.product.name,
          movement.user.name,
          movement.movement,
          format_currency(movement.price),
          format_currency(movement.movement * movement.price)
        ]
      end
  end
end
