class CameraSharesController < ApplicationController
  before_action :authorize_admin

  def index
  end

  def load_camera_shares
    col_for_order = params[:order]["0"]["column"]
    order_for = params[:order]["0"]["dir"]
    if params[:camera_exid].present?
      camera_exid = " and lower(exid) like lower('%#{params[:camera_exid]}%')"
    end
    if params[:sharer_fullname].present?
      sharer_fullname = " and lower(sharer.firstname || ' ' || sharer.lastname) like lower('%#{params[:sharer_fullname]}%')"
    end
    if params[:sharee_fullname].present?
      sharee_fullname = " and lower(sharee.firstname || ' ' || sharee.lastname) like lower('%#{params[:sharee_fullname]}%')"
    end

    camera_shares = CameraShare.connection.select_all("
            SELECT sharer.id sharer_id, sharer.firstname || ' ' || sharer.lastname sharer_fullname,
            sharer.api_id sharer_api_id, sharer.api_key sharer_api_key,
            sharee.id sharee_id, sharee.firstname || ' ' || sharee.lastname sharee_fullname,
            sharee.api_id sharee_api_id, sharee.api_key sharee_api_key,
            c.id camera_id, c.exid, cs.id, cs.kind, cs.message, cs.created_at FROM camera_shares cs
            left JOIN users sharee on cs.user_id = sharee.id
            left JOIN users sharer on cs.sharer_id = sharer.id
            left JOIN cameras c on cs.camera_id = c.id where 1=1 #{camera_exid}#{sharer_fullname}#{sharee_fullname} #{sorting(col_for_order, order_for)}")

    total_records = camera_shares.count
    display_length = params[:length].to_i
    display_length = display_length < 0 ? total_records : display_length
    display_start = params[:start].to_i
    table_draw = params[:draw].to_i

    index_end = display_start + display_length
    index_end = index_end > total_records ? total_records - 1 : index_end
    records = { data: [], draw: table_draw, recordsTotal: total_records, recordsFiltered: total_records }
    (display_start..index_end).each do |index|
      if camera_shares[index].present?
        records[:data][records[:data].count] = [
          camera_shares[index]["created_at"] ? DateTime.parse(camera_shares[index]["created_at"]).strftime("%A, %d %b %Y %l:%M %p") : "",
          camera_shares[index]["exid"],
          camera_shares[index]["sharer_fullname"],
          camera_shares[index]["sharee_fullname"],
          camera_shares[index]["kind"],
          camera_shares[index]["sharer_api_key"],
          camera_shares[index]["sharer_api_id"],
          camera_shares[index]["sharee_api_key"],
          camera_shares[index]["sharee_api_id"],
          camera_shares[index]["camera_id"],
          camera_shares[index]["sharer_id"],
          camera_shares[index]["sharee_id"],
          check_env
        ]
      end
    end
    render json: records
  end

  def sorting(col, order)
    case col
    when "1"
      "order by exid #{order}"
    when "2"
      "order by sharer_fullname #{order}"
    when "3"
      "order by sharee_fullname #{order}"
    when "4"
      "order by kind #{order}"
    when "0"
      "order by created_at #{order}"
    else
      "order by created_at desc"
    end
  end
end
